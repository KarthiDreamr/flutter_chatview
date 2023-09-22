/*
 * Copyright (c) 2022 Simform Solutions
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */
import 'package:chatview/src/extensions/extensions.dart';
import 'package:chatview/src/utils/measure_size.dart';
import 'package:chatview/src/widgets/reactions_bottomsheet.dart';
import 'package:flutter/material.dart';

import 'package:chatview/chatview.dart';

class ReactionWidget extends StatefulWidget {
  const ReactionWidget({
    Key? key,
    required this.message,
    this.messageReactionConfig,
    required this.isMessageBySender,
  }) : super(key: key);

  /// Provides reaction instance of message.
  final Message message;

  /// Provides configuration of reaction appearance in chat bubble.
  final MessageReactionConfiguration? messageReactionConfig;

  /// Represents current message is sent by current user.
  final bool isMessageBySender;

  @override
  State<ReactionWidget> createState() => _ReactionWidgetState();
}

class _ReactionWidgetState extends State<ReactionWidget> {
  bool needToExtend = false;

  MessageReactionConfiguration? get messageReactionConfig =>
      widget.messageReactionConfig;
  final _reactionTextStyle = const TextStyle(fontSize: 13);
  ChatController? chatController;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (provide != null) {
      chatController = provide!.chatController;
    }
  }

  @override
  Widget build(BuildContext context) {
    //// Convert into set to remove reduntant values
    final reactionsSet = widget.message.reaction.reactions.toSet();

    return Positioned(
      bottom: 0,
      right: widget.isMessageBySender && needToExtend ? 0 : null,
      child: InkWell(
        onTap: () => chatController != null
            ? ReactionsBottomSheet().show(
                context: context,
                reaction: widget.message.reaction,
                chatController: chatController!,
                reactionsBottomSheetConfig:
                    messageReactionConfig?.reactionsBottomSheetConfig,
              )
            : null,
        child: MeasureSize(
          onSizeChange: (extend) => setState(() => needToExtend = extend),
          child: Container(
            padding: messageReactionConfig?.padding ??
                const EdgeInsets.symmetric(vertical: 1, horizontal: 6),
            margin: messageReactionConfig?.margin ??
                EdgeInsets.only(
                  left: widget.isMessageBySender ? 10 : 16,
                  right: 10,
                ),
            decoration: BoxDecoration(
              color: messageReactionConfig?.backgroundColor ??
                  Colors.grey.shade300,
              borderRadius: messageReactionConfig?.borderRadius ??
                  BorderRadius.circular(16),
              border: Border.all(
                color: messageReactionConfig?.borderColor ?? Colors.white,
                width: messageReactionConfig?.borderWidth ?? 1,
              ),
            ),
            child: Row(
              children: [
                Text(
                  reactionsSet.join(' '),
                  style: TextStyle(
                    fontSize: messageReactionConfig?.reactionSize ?? 13,
                  ),
                ),
                if ((chatController?.chatUsers.length ?? 0) > 1) ...[
                  if (!(widget.message.reaction.reactedUserIds.length > 3) &&
                      !(reactionsSet.length > 1))
                    ...List.generate(
                      widget.message.reaction.reactedUserIds.length,
                      (reactedUserIndex) => widget
                          .message.reaction.reactedUserIds[reactedUserIndex]
                          .getUserProfilePicture(
                        getChatUser: (userId) =>
                            chatController?.getUserFromId(userId),
                        profileCirclePadding:
                            messageReactionConfig?.profileCirclePadding,
                        profileCircleRadius:
                            messageReactionConfig?.profileCircleRadius,
                      ),
                    ),
                  if (widget.message.reaction.reactedUserIds.length > 3 &&
                      !(reactionsSet.length > 1))
                    Padding(
                      padding: const EdgeInsets.only(left: 2),
                      child: Text(
                        '+${widget.message.reaction.reactedUserIds.length}',
                        style:
                            messageReactionConfig?.reactedUserCountTextStyle ??
                                _reactionTextStyle,
                      ),
                    ),
                  if (reactionsSet.length > 1)
                    Padding(
                      padding: const EdgeInsets.only(left: 2),
                      child: Text(
                        widget.message.reaction.reactedUserIds.length
                            .toString(),
                        style: messageReactionConfig?.reactionCountTextStyle ??
                            _reactionTextStyle,
                      ),
                    ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
