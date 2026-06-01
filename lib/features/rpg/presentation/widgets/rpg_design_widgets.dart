import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/rpg_theme.dart';
import '../../domain/domain.dart';

class RpgStage extends StatelessWidget {
  const RpgStage({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: RpgTheme.stageDecoration(),
      child: Stack(
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(-0.72, -0.86),
                  radius: 0.92,
                  colors: [
                    RpgTheme.gold.withValues(alpha: 0.12),
                    Colors.transparent,
                  ],
                  stops: const [0, 0.62],
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(0.78, 0.92),
                  radius: 1.02,
                  colors: [
                    RpgTheme.blood.withValues(alpha: 0.16),
                    Colors.transparent,
                  ],
                  stops: const [0, 0.66],
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(0, 0),
                  radius: 1.08,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.68),
                  ],
                  stops: const [0.4, 1],
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: RepaintBoundary(
              child: CustomPaint(painter: _RpgGrainPainter()),
            ),
          ),
          Positioned.fill(child: child),
        ],
      ),
    );
  }
}

class RpgPanel extends StatelessWidget {
  const RpgPanel({
    required this.child,
    this.padding = const EdgeInsets.all(14),
    this.margin,
    this.borderColor = RpgTheme.line,
    this.ornate = false,
    this.inset = false,
    this.raised = false,
    this.danger = false,
    this.doubleBorder = false,
    super.key,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final Color borderColor;
  final bool ornate;
  final bool inset;
  final bool raised;
  final bool danger;
  final bool doubleBorder;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      padding: padding,
      decoration: RpgTheme.panelDecoration(
        borderColor: borderColor,
        ornate: ornate,
        inset: inset,
        raised: raised,
        danger: danger,
      ),
      child: Stack(
        children: [
          child,
          if (doubleBorder || ornate)
            Positioned.fill(
              child: IgnorePointer(
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: borderColor.withValues(alpha: 0.42),
                      ),
                      borderRadius: BorderRadius.circular(RpgRadius.sm),
                    ),
                  ),
                ),
              ),
            ),
          if (ornate) ...[
            const Positioned(left: 0, top: 0, child: _RpgCorner(topLeft: true)),
            const Positioned(
              right: 0,
              bottom: 0,
              child: _RpgCorner(topLeft: false),
            ),
          ],
        ],
      ),
    );
  }
}

class RpgPanelHeader extends StatelessWidget {
  const RpgPanelHeader({
    required this.title,
    this.subtitle,
    this.icon,
    this.trailing,
    this.dense = false,
    super.key,
  });

  final String title;
  final String? subtitle;
  final IconData? icon;
  final Widget? trailing;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: dense ? 10 : 14,
        vertical: dense ? 8 : 12,
      ),
      decoration: BoxDecoration(
        border: const Border(bottom: BorderSide(color: RpgTheme.line)),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [RpgTheme.gold.withValues(alpha: 0.035), Colors.transparent],
        ),
      ),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, color: RpgTheme.gold, size: dense ? 14 : 16),
            const SizedBox(width: 10),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title.toUpperCase(),
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.cinzel(
                    color: RpgTheme.inkBright,
                    fontSize: dense ? 11 : 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.7,
                  ),
                ),
                if (subtitle case final subtitleText?) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitleText,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: RpgTheme.mutedInk,
                      fontSize: 11,
                    ),
                  ),
                ],
              ],
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}

class RpgHairline extends StatelessWidget {
  const RpgHairline({this.gold = false, super.key});

  final bool gold;

  @override
  Widget build(BuildContext context) {
    final color = gold ? RpgTheme.lineGold : RpgTheme.line;
    return Container(
      height: gold ? 4 : 1,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.transparent,
            color.withValues(alpha: 0.75),
            gold ? RpgTheme.gold : color,
            color.withValues(alpha: 0.75),
            Colors.transparent,
          ],
        ),
      ),
    );
  }
}

class RpgOrnament extends StatelessWidget {
  const RpgOrnament({
    this.width = 180,
    this.color = RpgTheme.lineGold,
    super.key,
  });

  final double width;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: 18,
      child: CustomPaint(painter: _RpgOrnamentPainter(color)),
    );
  }
}

enum RpgButtonVariant { primary, ghost, danger }

class RpgButton extends StatefulWidget {
  const RpgButton({
    required this.label,
    required this.onPressed,
    this.icon,
    this.variant = RpgButtonVariant.ghost,
    this.small = false,
    this.expand = false,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final RpgButtonVariant variant;
  final bool small;
  final bool expand;

  @override
  State<RpgButton> createState() => _RpgButtonState();
}

class _RpgButtonState extends State<RpgButton> {
  bool _hovered = false;
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onPressed != null;
    final colors = switch (widget.variant) {
      RpgButtonVariant.primary => (
        border: RpgColors.goldDeep,
        foreground: RpgTheme.goldBright,
        top: const Color(0xff2a1f12),
        bottom: const Color(0xff1a140d),
      ),
      RpgButtonVariant.ghost => (
        border: RpgTheme.lineStrong,
        foreground: RpgTheme.mutedInk,
        top: Colors.transparent,
        bottom: Colors.transparent,
      ),
      RpgButtonVariant.danger => (
        border: const Color(0xff4a1414),
        foreground: const Color(0xffe8a0a0),
        top: const Color(0xff2a0c0c),
        bottom: const Color(0xff1a0707),
      ),
    };
    final interactive = enabled && (_hovered || _pressed);
    final borderColor = interactive
        ? RpgTheme.goldBright.withValues(
            alpha: widget.variant == RpgButtonVariant.danger ? 0.55 : 0.72,
          )
        : colors.border;

    final child = AnimatedOpacity(
      duration: const Duration(milliseconds: 120),
      opacity: enabled ? 1 : 0.35,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        transform: Matrix4.translationValues(0, _pressed ? 1 : 0, 0),
        child: Container(
          width: widget.expand ? double.infinity : null,
          padding: EdgeInsets.symmetric(
            horizontal: widget.small ? 10 : 14,
            vertical: widget.small ? 7 : 10,
          ),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color.lerp(colors.top, RpgTheme.gold, interactive ? 0.08 : 0)!,
                colors.bottom,
              ],
            ),
            border: Border.all(color: borderColor),
            borderRadius: BorderRadius.circular(RpgRadius.md),
            boxShadow: widget.variant == RpgButtonVariant.primary
                ? [
                    BoxShadow(
                      color: RpgTheme.gold.withValues(
                        alpha: interactive ? 0.18 : 0.05,
                      ),
                      blurRadius: interactive ? 16 : 0,
                      offset: const Offset(0, 1),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisSize: widget.expand ? MainAxisSize.max : MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.icon != null) ...[
                Icon(
                  widget.icon,
                  color: colors.foreground,
                  size: widget.small ? 13 : 15,
                ),
                SizedBox(width: widget.small ? 6 : 8),
              ],
              Flexible(
                child: Text(
                  widget.label.toUpperCase(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: RpgTextStyles.button(
                    size: widget.small ? 9.5 : 11,
                    color: colors.foreground,
                    weight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() {
        _hovered = false;
        _pressed = false;
      }),
      child: GestureDetector(
        onTapDown: enabled ? (_) => setState(() => _pressed = true) : null,
        onTapCancel: enabled ? () => setState(() => _pressed = false) : null,
        onTapUp: enabled ? (_) => setState(() => _pressed = false) : null,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onPressed,
            borderRadius: BorderRadius.circular(RpgRadius.md),
            child: child,
          ),
        ),
      ),
    );
  }
}

class RpgIconButton extends StatelessWidget {
  const RpgIconButton({
    required this.icon,
    required this.onPressed,
    this.tooltip,
    this.danger = false,
    super.key,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final String? tooltip;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final button = Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        color: Colors.transparent,
        border: Border.all(color: danger ? RpgTheme.blood : RpgTheme.line),
        borderRadius: BorderRadius.circular(RpgRadius.md),
      ),
      child: Icon(
        icon,
        size: 16,
        color: danger ? RpgTheme.danger : RpgTheme.mutedInk,
      ),
    );

    return Tooltip(
      message: tooltip ?? '',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(RpgRadius.md),
          child: button,
        ),
      ),
    );
  }
}

class RpgStepper extends StatelessWidget {
  const RpgStepper({
    required this.value,
    required this.onChanged,
    this.min = 0,
    this.max = 999,
    this.suffix,
    super.key,
  });

  final int value;
  final ValueChanged<int> onChanged;
  final int min;
  final int max;
  final String? suffix;

  @override
  Widget build(BuildContext context) {
    void setValue(int next) => onChanged(next.clamp(min, max));

    return Container(
      height: 34,
      decoration: BoxDecoration(
        color: RpgTheme.bgInset,
        border: Border.all(color: RpgTheme.lineStrong),
        borderRadius: BorderRadius.circular(RpgRadius.sm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _StepperTap(
            icon: Icons.remove,
            onPressed: value <= min ? null : () => setValue(value - 1),
          ),
          Container(width: 1, height: 34, color: RpgTheme.line),
          SizedBox(
            width: suffix == null ? 54 : 78,
            child: Center(
              child: Text(
                suffix == null ? '$value' : '$value $suffix',
                style: RpgTextStyles.mono(size: 14, weight: FontWeight.w700),
              ),
            ),
          ),
          Container(width: 1, height: 34, color: RpgTheme.line),
          _StepperTap(
            icon: Icons.add,
            onPressed: value >= max ? null : () => setValue(value + 1),
          ),
        ],
      ),
    );
  }
}

class RpgMetaPill extends StatelessWidget {
  const RpgMetaPill({
    required this.label,
    required this.value,
    this.icon,
    super.key,
  });

  final String label;
  final String value;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return RpgPanel(
      inset: true,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null) ...[
            Icon(icon, color: RpgTheme.gold, size: 14),
            const SizedBox(width: 6),
          ],
          Flexible(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label.toUpperCase(),
                  overflow: TextOverflow.ellipsis,
                  style: RpgTextStyles.eyebrow(size: 8.5),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  overflow: TextOverflow.ellipsis,
                  style: RpgTextStyles.mono(size: 13, weight: FontWeight.w700),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class RpgCrest extends StatelessWidget {
  const RpgCrest({this.size = 120, this.compact = false, super.key});

  final double size;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size * (compact ? 1.08 : 1.16),
      child: CustomPaint(painter: _RpgCrestPainter()),
    );
  }
}

class RpgSectionTitle extends StatelessWidget {
  const RpgSectionTitle({
    required this.title,
    this.subtitle,
    this.icon,
    this.accent = RpgTheme.gold,
    super.key,
  });

  final String title;
  final String? subtitle;
  final IconData? icon;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (icon != null) ...[
          Icon(icon, color: accent, size: 17),
          const SizedBox(width: 8),
        ],
        Text(
          title.toUpperCase(),
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            color: accent,
            fontSize: 12,
            letterSpacing: 1.8,
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(width: 10),
          Flexible(
            child: Text(
              subtitle!,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: RpgTheme.mutedInk, fontSize: 12),
            ),
          ),
        ],
        const SizedBox(width: 12),
        const Expanded(child: Divider(height: 1)),
      ],
    );
  }
}

class RpgTabs<T> extends StatelessWidget {
  const RpgTabs({
    required this.tabs,
    required this.value,
    required this.onChanged,
    this.dense = false,
    super.key,
  });

  final List<RpgTabItem<T>> tabs;
  final T value;
  final ValueChanged<T> onChanged;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: RpgTheme.line)),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            for (final tab in tabs)
              _RpgTabButton<T>(
                tab: tab,
                active: tab.value == value,
                dense: dense,
                onPressed: () => onChanged(tab.value),
              ),
            const SizedBox(width: RpgSpacing.lg),
          ],
        ),
      ),
    );
  }
}

class RpgTabItem<T> {
  const RpgTabItem({
    required this.value,
    required this.label,
    this.icon,
    this.badge,
  });

  final T value;
  final String label;
  final IconData? icon;
  final int? badge;
}

class _RpgTabButton<T> extends StatelessWidget {
  const _RpgTabButton({
    required this.tab,
    required this.active,
    required this.dense,
    required this.onPressed,
  });

  final RpgTabItem<T> tab;
  final bool active;
  final bool dense;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style:
          TextButton.styleFrom(
            foregroundColor: active ? RpgTheme.goldBright : RpgTheme.mutedInk,
            padding: EdgeInsets.symmetric(
              horizontal: dense ? 12 : 16,
              vertical: dense ? 9 : 13,
            ),
            shape: const RoundedRectangleBorder(),
          ).copyWith(
            side: WidgetStatePropertyAll(
              BorderSide(
                color: active ? RpgTheme.gold : Colors.transparent,
                width: 0,
              ),
            ),
          ),
      child: Container(
        padding: const EdgeInsets.only(bottom: 4),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: active ? RpgTheme.gold : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (tab.icon != null) ...[
              Icon(tab.icon, size: 14),
              const SizedBox(width: 7),
            ],
            Text(
              tab.label.toUpperCase(),
              style: GoogleFonts.cinzel(
                fontSize: dense ? 10 : 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.45,
              ),
            ),
            if (tab.badge != null) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                decoration: BoxDecoration(
                  color: active ? RpgTheme.lineGold : RpgTheme.line,
                  borderRadius: BorderRadius.circular(2),
                ),
                child: Text(
                  '${tab.badge}',
                  style: GoogleFonts.jetBrainsMono(
                    color: active ? RpgTheme.bgDeep : RpgTheme.ink,
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class RpgHpBar extends StatelessWidget {
  const RpgHpBar({
    required this.current,
    required this.max,
    this.showLabel = true,
    this.height = 10,
    super.key,
  });

  final int current;
  final int max;
  final bool showLabel;
  final double height;

  @override
  Widget build(BuildContext context) {
    final percent = max <= 0 ? 0.0 : (current / max).clamp(0.0, 1.0);
    final color = current <= 0
        ? RpgTheme.inkDim
        : percent <= 0.25
        ? RpgTheme.danger
        : percent <= 0.5
        ? RpgTheme.ochre
        : RpgTheme.mossBright;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (showLabel) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'VIDA',
                style: TextStyle(
                  color: RpgTheme.mutedInk,
                  fontSize: 11,
                  letterSpacing: 0.8,
                ),
              ),
              Text(
                '$current / $max',
                style: GoogleFonts.jetBrainsMono(
                  color: RpgTheme.inkBright,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
        ],
        ClipRRect(
          borderRadius: BorderRadius.circular(RpgRadius.sm),
          child: Stack(
            children: [
              Container(
                height: height,
                decoration: BoxDecoration(
                  color: RpgTheme.bgInset,
                  border: Border.all(color: RpgTheme.line, width: 0.6),
                ),
              ),
              FractionallySizedBox(
                widthFactor: 1,
                child: TweenAnimationBuilder<double>(
                  duration: const Duration(milliseconds: 520),
                  curve: Curves.easeOutCubic,
                  tween: Tween(begin: 0, end: percent),
                  builder: (context, value, _) => FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: value,
                    child: _HpFill(
                      height: height,
                      color: color,
                      pulse: current > 0 && percent <= 0.25,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _HpFill extends StatefulWidget {
  const _HpFill({
    required this.height,
    required this.color,
    required this.pulse,
  });

  final double height;
  final Color color;
  final bool pulse;

  @override
  State<_HpFill> createState() => _HpFillState();
}

class _HpFillState extends State<_HpFill> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    if (widget.pulse) _controller.repeat(reverse: true);
  }

  @override
  void didUpdateWidget(covariant _HpFill oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.pulse && !_controller.isAnimating) {
      _controller.repeat(reverse: true);
    } else if (!widget.pulse && _controller.isAnimating) {
      _controller.stop();
      _controller.value = 0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final glow = widget.pulse ? 0.12 + (_controller.value * 0.28) : 0.08;
        return Container(
          height: widget.height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                widget.color.withValues(alpha: 0.72),
                widget.color,
                RpgTheme.goldBright.withValues(alpha: glow),
              ],
            ),
          ),
        );
      },
    );
  }
}

class RpgPortrait extends StatelessWidget {
  const RpgPortrait({
    required this.label,
    this.icon = Icons.shield,
    this.sigil,
    this.showLabel = false,
    this.ringColor,
    this.size = 52,
    this.color = RpgTheme.gold,
    super.key,
  });

  final String label;
  final IconData icon;
  final String? sigil;
  final bool showLabel;
  final Color? ringColor;
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final accent = ringColor ?? color;
    return SizedBox(
      width: size,
      height: showLabel ? size + 12 : size,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xff1a140d), Color(0xff0c0805)],
                ),
                border: Border.all(color: accent),
                boxShadow: [
                  BoxShadow(
                    color: accent.withValues(alpha: 0.18),
                    blurRadius: 18,
                  ),
                ],
              ),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: ClipOval(
                      child: CustomPaint(painter: _RpgStripePainter(accent)),
                    ),
                  ),
                  Center(
                    child: Icon(
                      sigil == null ? icon : _sigilIcon(sigil!),
                      color: accent,
                      size: size * 0.45,
                    ),
                  ),
                  Positioned.fill(
                    child: Padding(
                      padding: const EdgeInsets.all(3),
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: RpgTheme.goldBright.withValues(alpha: 0.12),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (showLabel)
            Positioned(
              bottom: 0,
              child: Container(
                constraints: BoxConstraints(maxWidth: size + 34),
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: RpgTheme.bgDeep,
                  border: Border.all(color: RpgColors.goldDeep),
                  borderRadius: BorderRadius.circular(RpgRadius.sm),
                ),
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: RpgTextStyles.mono(
                    size: 9,
                    color: RpgTheme.goldBright,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class RpgStatBadge extends StatelessWidget {
  const RpgStatBadge({
    required this.label,
    required this.value,
    this.accent = false,
    this.max,
    super.key,
  });

  final String label;
  final int value;
  final bool accent;
  final int? max;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 48),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
      decoration: BoxDecoration(
        color: accent
            ? RpgTheme.lineGold.withValues(alpha: 0.12)
            : RpgTheme.bgInset,
        border: Border.all(color: accent ? RpgTheme.lineGold : RpgTheme.line),
        borderRadius: BorderRadius.circular(2),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label.toUpperCase(),
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.cinzel(
              color: RpgTheme.mutedInk,
              fontSize: 9,
              fontWeight: FontWeight.w700,
              letterSpacing: 0,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${value >= 0 ? '+' : ''}$value',
            style: GoogleFonts.jetBrainsMono(
              color: accent ? RpgTheme.goldBright : RpgTheme.inkBright,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          if (max != null)
            Text(
              'max $max',
              style: const TextStyle(color: RpgTheme.inkDim, fontSize: 9),
            ),
        ],
      ),
    );
  }
}

class RpgStatChip extends StatelessWidget {
  const RpgStatChip({
    required this.label,
    required this.value,
    this.icon,
    super.key,
  });

  final String label;
  final String value;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: RpgTheme.bgInset,
        border: Border.all(color: RpgTheme.lineStrong),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, color: RpgTheme.gold, size: 15),
            const SizedBox(width: 6),
          ],
          Text(
            '$label: ',
            style: const TextStyle(color: RpgTheme.mutedInk, fontSize: 12),
          ),
          Flexible(
            child: Text(
              value,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: RpgTheme.inkBright,
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class RpgSegmentedControl<T> extends StatelessWidget {
  const RpgSegmentedControl({
    required this.items,
    required this.value,
    required this.onChanged,
    super.key,
  });

  final List<RpgTabItem<T>> items;
  final T value;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    return RpgPanel(
      inset: true,
      padding: const EdgeInsets.all(3),
      child: Row(
        children: [
          for (final item in items)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(2),
                child: FilledButton.tonal(
                  onPressed: () => onChanged(item.value),
                  style: FilledButton.styleFrom(
                    backgroundColor: item.value == value
                        ? RpgTheme.lineGold
                        : Colors.transparent,
                    foregroundColor: item.value == value
                        ? RpgTheme.bgDeep
                        : RpgTheme.mutedInk,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  child: Text(item.label),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class RpgStateLamp extends StatelessWidget {
  const RpgStateLamp({required this.state, super.key});

  final DefeatedState state;

  @override
  Widget build(BuildContext context) {
    final color = switch (state) {
      DefeatedState.active => RpgTheme.mossBright,
      DefeatedState.unconscious => RpgTheme.ochre,
      DefeatedState.defeated => RpgTheme.danger,
      DefeatedState.dead => RpgTheme.charcoal,
    };

    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.55),
            blurRadius: state == DefeatedState.active ? 10 : 8,
          ),
        ],
      ),
    );
  }
}

class RpgModal extends StatelessWidget {
  const RpgModal({
    this.title,
    this.eyebrow,
    this.content,
    this.actions,
    this.width = 560,
    super.key,
  });

  final Widget? title;
  final String? eyebrow;
  final Widget? content;
  final List<Widget>? actions;
  final double width;

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final safeWidth = (media.size.width - RpgSpacing.xl * 2)
        .clamp(280.0, width)
        .toDouble();
    final safeHeight = (media.size.height - RpgSpacing.xl * 2)
        .clamp(320.0, media.size.height)
        .toDouble();

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
      child: Dialog(
        insetPadding: const EdgeInsets.all(RpgSpacing.xl),
        backgroundColor: Colors.transparent,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: safeWidth,
            maxHeight: safeHeight,
          ),
          child: RpgPanel(
            ornate: true,
            raised: true,
            doubleBorder: true,
            borderColor: RpgTheme.lineGold,
            padding: EdgeInsets.zero,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (title != null)
                  RpgPanelHeader(
                    title: _plainText(title!) ?? 'Diálogo',
                    subtitle: eyebrow,
                    trailing: IconButton(
                      tooltip: 'Fechar',
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close, size: 16),
                    ),
                  ),
                if (content != null)
                  Flexible(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(RpgSpacing.lg),
                      child: content!,
                    ),
                  ),
                if (actions != null && actions!.isNotEmpty) ...[
                  const RpgHairline(),
                  Padding(
                    padding: const EdgeInsets.all(14),
                    child: Wrap(
                      alignment: WrapAlignment.end,
                      spacing: RpgSpacing.sm,
                      runSpacing: RpgSpacing.sm,
                      children: actions!,
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

  String? _plainText(Widget widget) {
    if (widget is Text) {
      final data = widget.data;
      if (data != null) return data;
    }
    return null;
  }
}

class RpgFormSection extends StatelessWidget {
  const RpgFormSection({
    required this.title,
    required this.children,
    this.subtitle,
    this.icon,
    super.key,
  });

  final String title;
  final String? subtitle;
  final IconData? icon;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: RpgSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          RpgSectionTitle(title: title, subtitle: subtitle, icon: icon),
          const SizedBox(height: RpgSpacing.md),
          RpgFieldGroup(children: children),
        ],
      ),
    );
  }
}

class RpgFieldGroup extends StatelessWidget {
  const RpgFieldGroup({
    required this.children,
    this.gap = RpgSpacing.md,
    super.key,
  });

  final List<Widget> children;
  final double gap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var index = 0; index < children.length; index += 1) ...[
          if (index > 0) SizedBox(height: gap),
          children[index],
        ],
      ],
    );
  }
}

class RpgFieldGrid extends StatelessWidget {
  const RpgFieldGrid({
    required this.children,
    this.minColumnWidth = 180,
    this.columnGap = RpgSpacing.md,
    this.rowGap = RpgSpacing.sm,
    super.key,
  });

  final List<Widget> children;
  final double minColumnWidth;
  final double columnGap;
  final double rowGap;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : minColumnWidth;
        final columns = ((maxWidth + columnGap) / (minColumnWidth + columnGap))
            .floor()
            .clamp(1, 4);
        final width = (maxWidth - (columnGap * (columns - 1))) / columns;
        return Wrap(
          spacing: columnGap,
          runSpacing: rowGap,
          children: [
            for (final child in children) SizedBox(width: width, child: child),
          ],
        );
      },
    );
  }
}

class RpgInfoRow extends StatelessWidget {
  const RpgInfoRow({
    required this.label,
    required this.value,
    this.icon,
    super.key,
  });

  final String label;
  final String value;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    if (value.trim().isEmpty) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: RpgSpacing.md,
        vertical: RpgSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: RpgTheme.bgInset,
        border: Border.all(color: RpgTheme.line),
        borderRadius: BorderRadius.circular(RpgRadius.sm),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[
            Icon(icon, color: RpgTheme.gold, size: 14),
            const SizedBox(width: RpgSpacing.sm),
          ],
          Text(
            '${label.toUpperCase()}: ',
            style: RpgTextStyles.eyebrow(size: 9),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: RpgTheme.mutedInk, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}

class RpgSearchField extends StatelessWidget {
  const RpgSearchField({
    required this.controller,
    required this.onChanged,
    this.hintText = 'Buscar',
    super.key,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final String hintText;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: const Icon(Icons.search, size: 18),
        suffixIcon: controller.text.isEmpty
            ? null
            : IconButton(
                tooltip: 'Limpar busca',
                icon: const Icon(Icons.close, size: 16),
                onPressed: () {
                  controller.clear();
                  onChanged('');
                },
              ),
      ),
    );
  }
}

class _StepperTap extends StatelessWidget {
  const _StepperTap({required this.icon, required this.onPressed});

  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      child: SizedBox(
        width: 34,
        height: 34,
        child: Icon(
          icon,
          size: 14,
          color: onPressed == null ? RpgTheme.inkDim : RpgTheme.mutedInk,
        ),
      ),
    );
  }
}

class _RpgCorner extends StatelessWidget {
  const _RpgCorner({required this.topLeft});

  final bool topLeft;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 16,
      height: 16,
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border(
            top: topLeft
                ? const BorderSide(color: RpgColors.goldDeep)
                : BorderSide.none,
            left: topLeft
                ? const BorderSide(color: RpgColors.goldDeep)
                : BorderSide.none,
            right: topLeft
                ? BorderSide.none
                : const BorderSide(color: RpgColors.goldDeep),
            bottom: topLeft
                ? BorderSide.none
                : const BorderSide(color: RpgColors.goldDeep),
          ),
        ),
      ),
    );
  }
}

IconData _sigilIcon(String sigil) {
  return switch (sigil.toLowerCase()) {
    'sword' || 'swords' || 'guerreiro' => Icons.local_fire_department,
    'shield' || 'clerigo' || 'clérigo' => Icons.shield,
    'rune' || 'mago' => Icons.auto_awesome,
    'moon' || 'ladino' => Icons.nightlight_round,
    'crown' || 'master' || 'mestre' => Icons.workspace_premium,
    'skull' || 'monster' || 'monstro' => Icons.dangerous,
    'fire' => Icons.local_fire_department,
    _ => Icons.shield,
  };
}

class _RpgGrainPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = RpgTheme.gold.withValues(alpha: 0.008)
      ..strokeWidth = 1;
    for (var x = -size.height * 0.24; x < size.width; x += 17) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x + size.height * 0.18, size.height),
        linePaint,
      );
    }

    final dotPaint = Paint()..color = RpgTheme.gold.withValues(alpha: 0.014);
    for (var y = 0.0; y < size.height; y += 23) {
      for (var x = (y % 47) / 2; x < size.width; x += 37) {
        final seed = ((x * 17 + y * 31).round() % 9) / 9;
        canvas.drawCircle(
          Offset(x + seed * 2, y),
          0.35 + seed * 0.35,
          dotPaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _RpgCrestPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final outer = Path()
      ..moveTo(w * 0.5, h * 0.04)
      ..lineTo(w * 0.9, h * 0.16)
      ..lineTo(w * 0.9, h * 0.5)
      ..cubicTo(w * 0.9, h * 0.76, w * 0.75, h * 0.92, w * 0.5, h * 0.98)
      ..cubicTo(w * 0.25, h * 0.92, w * 0.1, h * 0.76, w * 0.1, h * 0.5)
      ..lineTo(w * 0.1, h * 0.16)
      ..close();
    final inner = Path()
      ..moveTo(w * 0.5, h * 0.11)
      ..lineTo(w * 0.82, h * 0.21)
      ..lineTo(w * 0.82, h * 0.51)
      ..cubicTo(w * 0.82, h * 0.7, w * 0.69, h * 0.84, w * 0.5, h * 0.91)
      ..cubicTo(w * 0.31, h * 0.84, w * 0.18, h * 0.7, w * 0.18, h * 0.51)
      ..lineTo(w * 0.18, h * 0.21)
      ..close();

    final fill = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [RpgTheme.bgRaised, RpgTheme.bgDeep],
      ).createShader(Offset.zero & size);
    final stroke = Paint()
      ..color = RpgColors.goldDeep
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    final gold = Paint()
      ..color = RpgTheme.gold
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(outer, fill);
    canvas.drawPath(outer, stroke);
    canvas.drawPath(
      inner,
      stroke..color = RpgColors.goldDeep.withValues(alpha: 0.6),
    );

    final center = Offset(w * 0.5, h * 0.52);
    canvas.drawLine(
      center + Offset(-w * 0.19, -h * 0.18),
      center + Offset(w * 0.19, h * 0.18),
      gold,
    );
    canvas.drawLine(
      center + Offset(w * 0.19, -h * 0.18),
      center + Offset(-w * 0.19, h * 0.18),
      gold,
    );
    canvas.drawCircle(center, w * 0.028, Paint()..color = RpgTheme.gold);
    canvas.drawCircle(
      Offset(w * 0.5, h * 0.22),
      w * 0.018,
      Paint()..color = RpgTheme.gold,
    );
    canvas.drawCircle(
      Offset(w * 0.3, h * 0.34),
      w * 0.012,
      Paint()..color = RpgColors.goldDeep,
    );
    canvas.drawCircle(
      Offset(w * 0.7, h * 0.34),
      w * 0.012,
      Paint()..color = RpgColors.goldDeep,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _RpgOrnamentPainter extends CustomPainter {
  const _RpgOrnamentPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    final y = size.height / 2;
    canvas.drawLine(Offset(0, y), Offset(size.width * 0.38, y), paint);
    canvas.drawLine(Offset(size.width * 0.62, y), Offset(size.width, y), paint);
    canvas.drawCircle(Offset(size.width / 2, y), 4, paint);
    canvas.drawCircle(Offset(size.width / 2, y), 1.5, Paint()..color = color);
    canvas.drawLine(
      Offset(size.width * 0.44, y - 5),
      Offset(size.width * 0.5, y),
      paint,
    );
    canvas.drawLine(
      Offset(size.width * 0.56, y - 5),
      Offset(size.width * 0.5, y),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _RpgOrnamentPainter oldDelegate) =>
      oldDelegate.color != color;
}

class _RpgStripePainter extends CustomPainter {
  const _RpgStripePainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: 0.12)
      ..strokeWidth = 1;
    for (var i = -size.height; i < size.width; i += 7) {
      canvas.drawLine(
        Offset(i, size.height),
        Offset(i + size.height, 0),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _RpgStripePainter oldDelegate) =>
      oldDelegate.color != color;
}
