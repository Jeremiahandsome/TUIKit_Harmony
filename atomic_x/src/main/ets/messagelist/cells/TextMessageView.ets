import { MessageInfo } from '@tencentcloud/atomicxcore';
import { ThemeState, LanguageState } from '../../basecomponent/Index';
import { MessageBody } from '@tencentcloud/atomicxcore';
import { EmojiDataManager, EmojiTextSegment } from '../../emojipicker/Index';
import { MessageListStyleProtocol } from '../config/MessageListConfig';
import { MessageRenderContext } from '../context/MessageRenderContext';

@Component
export struct TextMessageViewContent {
  @StorageLink('ThemeState') themeState: ThemeState = ThemeState.getInstance();
  @StorageLink('LanguageState') languageState: LanguageState = LanguageState.getInstance();
  @State message?: MessageInfo = undefined;
  @ObjectLink messageBody: MessageBody;
  @Prop config?: MessageListStyleProtocol = undefined;
  @Prop isInMergedDetailView: boolean = false;
  @State private parsedSegments: EmojiTextSegment[] = [];

  aboutToAppear() {
    this.updateParsedSegments();
  }

  aboutToUpdate() {
    this.updateParsedSegments();
  }

  build() {
    Column() {
      // Text content
      Text() {
        ForEach(this.parsedSegments, (segment: EmojiTextSegment, index: number) => {
          if (segment.type === 'text') {
            Span(segment.content)
          } else if (segment.type === 'emoji' && segment.imageFile) {
            ImageSpan(EmojiDataManager.getEmojiImageResource(segment.imageFile))
              .width(20)
              .height(20)
              .objectFit(ImageFit.Contain)
              .verticalAlign(ImageSpanAlignment.CENTER)
          }
        }, (segment: EmojiTextSegment, index: number) => `${segment.type}_${index}_${segment.content}`)
      }
      .fontSize(15)
      .fontColor(this.message?.isSelf ?
        this.themeState.colors.textColorAntiPrimary :
        this.themeState.colors.textColorPrimary)
      .textOverflow({ overflow: TextOverflow.None })
      .maxLines(999)
      .wordBreak(WordBreak.BREAK_ALL)
      .direction(this.languageState.getLayoutDirection() === LayoutDirection.RTL ? Direction.Rtl : Direction.Ltr)
    }
    .padding({
      left: 8,
      right: 8,
      top: 8,
      bottom: 6
    })
  }

  private updateParsedSegments() {
    const text = this.messageBody?.text ?? '';
    this.parsedSegments = EmojiDataManager.parseEmojiText(text);
  }
}

@Builder
export function TextMessageView(context: MessageRenderContext) {
  if (context.message && context.message.messageBody) {
    TextMessageViewContent({
      message: context.message,
      messageBody: context.message.messageBody,
      config: context.config,
      isInMergedDetailView: context.isInMergedDetailView ?? false
    })
  }
}
