import 'package:bili_you/pages/test/piliplus_reply_model.dart';
import 'package:flutter/material.dart';

/// PiliPlus风格的评论项组件
class PiliPlusReplyItemWidget extends StatefulWidget {
  final PiliPlusReplyItem comment;
  final int replyLevel;
  final Function(PiliPlusReplyItem comment, int? rpid)? onReply;
  final bool needDivider;
  final int? upMid;

  const PiliPlusReplyItemWidget({
    Key? key,
    required this.comment,
    this.replyLevel = 0,
    this.onReply,
    this.needDivider = true,
    this.upMid,
  }) : super(key: key);

  @override
  State<PiliPlusReplyItemWidget> createState() => _PiliPlusReplyItemWidgetState();
}

class _PiliPlusReplyItemWidgetState extends State<PiliPlusReplyItemWidget> {
  late PiliPlusReplyItem _comment;

  @override
  void initState() {
    super.initState();
    _comment = widget.comment;
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: () {
          // 点击评论项
          widget.onReply?.call(_comment, _comment.rpid);
        },
        child: _buildContent(context, theme),
      ),
    );
  }

  Widget _buildContent(BuildContext context, ThemeData theme) {
    return Column(
      children: [
        _buildAuthorPanel(context, theme),
        if (widget.needDivider)
          Divider(
            indent: 55,
            endIndent: 15,
            height: 0.3,
            color: theme.colorScheme.outline.withOpacity(0.08),
          ),
      ],
    );
  }

  Widget _buildAuthorPanel(BuildContext context, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 14, 8, 5),
      child: _content(context, theme),
    );
  }

  Widget _content(BuildContext context, ThemeData theme) {
    final padding = EdgeInsets.only(
      left: widget.replyLevel == 0 ? 6 : 45,
      right: 6,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            const CircleAvatar(
              radius: 17,
              backgroundColor: Colors.grey,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          _comment.name,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                      ),
                      Text(
                        _formatTime(_comment.replyTime),
                        style: TextStyle(
                          fontSize: 12,
                          color: theme.colorScheme.outline,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      if (_comment.isVip)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 4, vertical: 1),
                          decoration: BoxDecoration(
                            color: Colors.pink.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(2),
                          ),
                          child: Text(
                            '大会员',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.pink,
                            ),
                          ),
                        ),
                      if (widget.upMid != null && _comment.mid == widget.upMid)
                        Container(
                          margin: const EdgeInsets.only(left: 4),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 4, vertical: 1),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(2),
                          ),
                          child: Text(
                            'UP主',
                            style: TextStyle(
                              fontSize: 10,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Padding(
          padding: padding,
          child: Text(
            _comment.message,
            style: const TextStyle(fontSize: 14),
          ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: padding,
          child: Row(
            children: [
              IconButton(
                onPressed: () {
                  setState(() {
                    _comment.hasLike = !_comment.hasLike;
                    _comment.likeCount += _comment.hasLike ? 1 : -1;
                  });
                },
                icon: Icon(
                  _comment.hasLike
                      ? Icons.favorite
                      : Icons.favorite_border_outlined,
                  size: 18,
                  color: _comment.hasLike
                      ? Colors.pink
                      : theme.colorScheme.outline,
                ),
              ),
              Text(
                '${_comment.likeCount}',
                style: TextStyle(
                  fontSize: 12,
                  color: theme.colorScheme.outline,
                ),
              ),
              const SizedBox(width: 16),
              IconButton(
                onPressed: () {
                  // 回复功能
                  widget.onReply?.call(_comment, _comment.rpid);
                },
                icon: Icon(
                  Icons.reply,
                  size: 18,
                  color: theme.colorScheme.outline,
                ),
              ),
              Text(
                '${_comment.replyCount}',
                style: TextStyle(
                  fontSize: 12,
                  color: theme.colorScheme.outline,
                ),
              ),
            ],
          ),
        ),
        if (_comment.preReplies.isNotEmpty) ...[
          const SizedBox(height: 8),
          Padding(
            padding: padding,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceVariant.withOpacity(0.5),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Column(
                children: [
                  for (var preReply in _comment.preReplies)
                    _buildPreReply(preReply, theme),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildPreReply(PiliPlusReplyItem preReply, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              preReply.name,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              _formatTime(preReply.replyTime),
              style: TextStyle(
                fontSize: 11,
                color: theme.colorScheme.outline,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          preReply.message,
          style: TextStyle(
            fontSize: 12,
            color: theme.colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  String _formatTime(int timestamp) {
    if (timestamp == 0) return '未知时间';
    final now = DateTime.now();
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    final difference = now.difference(date);
    
    if (difference.inMinutes < 1) {
      return '刚刚';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}分钟前';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}小时前';
    } else if (difference.inDays < 365) {
      return '${date.month}-${date.day}';
    } else {
      return '${date.year}-${date.month}-${date.day}';
    }
  }
}