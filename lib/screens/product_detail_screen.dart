import 'package:flutter/material.dart';
import 'package:foodie_app/screens/homeScreen.dart';
import 'package:provider/provider.dart';
import '../models/food_item.dart';
import '../providers/cart_provider.dart';
import '../providers/wishlist_provider.dart';
import 'cart_screen.dart';

class ProductDetailScreen extends StatefulWidget {
  final FoodItem item;
  const ProductDetailScreen({super.key, required this.item});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen>
    with SingleTickerProviderStateMixin {
  int _localQty = 1; 
  static const _orange = Color(0xFFE07B39);

  OverlayEntry? _overlayEntry;

  final GlobalKey _imageKey = GlobalKey();

  void _triggerFlyAnimation() {
    final RenderBox? imageBox =
        _imageKey.currentContext?.findRenderObject() as RenderBox?;
    final RenderBox? cartBox =
        HomeScreen.cartIconKey.currentContext?.findRenderObject()
            as RenderBox?;

    if (imageBox == null || cartBox == null) return;

    final imagePos = imageBox.localToGlobal(Offset.zero);
    final imageSize = imageBox.size;
    final cartPos = cartBox.localToGlobal(Offset.zero);

    final startOffset = Offset(
      imagePos.dx + imageSize.width / 2,
      imagePos.dy + imageSize.height / 2,
    );
    final endOffset = Offset(cartPos.dx + 24, cartPos.dy + 24);

    final overlay = Overlay.of(context);
    _overlayEntry = OverlayEntry(
      builder: (_) => _FlyingDot(
        startOffset: startOffset,
        endOffset: endOffset,
        imageUrl: widget.item.imageUrl,
        onComplete: () {
          _overlayEntry?.remove();
          _overlayEntry = null;
        },
      ),
    );
    overlay.insert(_overlayEntry!);
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final wishlist = context.watch<WishlistProvider>();

    final inCart = cart.isInCart(widget.item.id);
    final cartQty = cart.quantityOf(widget.item.id);
    final isWishlisted = wishlist.isWishlisted(widget.item.id);

    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F3),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: _orange,
            iconTheme: const IconThemeData(color: Colors.white),
            flexibleSpace: FlexibleSpaceBar(
              background: RepaintBoundary(
                key: _imageKey,
                child: Image.network(
                  widget.item.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: Colors.grey[300],
                    child: const Icon(Icons.fastfood,
                        size: 80, color: Colors.grey),
                  ),
                ),
              ),
            ),
            actions: [
              Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.92),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 6)
                  ],
                ),
                child: IconButton(
                  icon: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    transitionBuilder: (child, anim) =>
                        ScaleTransition(scale: anim, child: child),
                    child: Icon(
                      isWishlisted ? Icons.favorite : Icons.favorite_border,
                      key: ValueKey(isWishlisted),
                      color: isWishlisted ? Colors.red : _orange,
                    ),
                  ),
                  onPressed: () => wishlist.toggle(widget.item),
                ),
              ),
            ],
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          widget.item.name,
                          style: const TextStyle(
                              fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '₹${widget.item.price.toInt()}',
                        style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: _orange),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  Row(
                    children: [
                      const Icon(Icons.star, size: 18, color: _orange),
                      const SizedBox(width: 4),
                      Text('${widget.item.rating}',
                          style: const TextStyle(fontWeight: FontWeight.w600)),
                      Text(' (${widget.item.reviewCount} Reviews)',
                          style: const TextStyle(color: Colors.grey)),
                      const Spacer(),
                      GestureDetector(
                        onTap: () => wishlist.toggle(widget.item),
                        child: Row(
                          children: [
                            Icon(
                              isWishlisted
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              size: 16,
                              color: isWishlisted ? Colors.red : Colors.grey,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              isWishlisted ? 'Wishlisted' : 'Wishlist',
                              style: TextStyle(
                                  fontSize: 13,
                                  color: isWishlisted
                                      ? Colors.red
                                      : Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),
                  const Divider(),
                  const SizedBox(height: 16),

                  // Description
                  const Text('Description',
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(
                    widget.item.description,
                    style: const TextStyle(
                        color: Colors.grey, height: 1.6, fontSize: 14),
                  ),

                  const SizedBox(height: 24),

                  // ── Quantity Selector (local, before adding) ──
                  // Only show if item NOT yet in cart
                  if (!inCart) ...[
                    const Text('Quantity',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _QtyBtn(
                          icon: Icons.remove,
                          onTap: () {
                            if (_localQty > 1)
                              setState(() => _localQty--);
                          },
                        ),
                        Padding(
                          padding:
                              const EdgeInsets.symmetric(horizontal: 20),
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 200),
                            transitionBuilder: (child, anim) =>
                                ScaleTransition(scale: anim, child: child),
                            child: Text(
                              '$_localQty',
                              key: ValueKey(_localQty),
                              style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        _QtyBtn(
                          icon: Icons.add,
                          onTap: () => setState(() => _localQty++),
                        ),
                        const SizedBox(width: 16),
                        Text(
                          'Total: ₹${(widget.item.price * _localQty).toInt()}',
                          style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              color: _orange,
                              fontSize: 15),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                  ],

                  // ── If already in cart: show inline cart qty control ──
                  if (inCart) ...[
                    Container(
                      padding: const EdgeInsets.all(14),
                      margin: const EdgeInsets.only(bottom: 24),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE07B39).withOpacity(0.08),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: _orange.withOpacity(0.3), width: 1),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.shopping_cart,
                              color: _orange, size: 20),
                          const SizedBox(width: 10),
                          const Text('In your cart',
                              style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: _orange)),
                          const Spacer(),
                          // Inline qty control
                          _CartQtyControl(
                            qty: cartQty,
                            onDecrement: () =>
                                cart.decrement(widget.item.id),
                            onIncrement: () {
                              cart.increment(widget.item.id);
                              _triggerFlyAnimation();
                            },
                          ),
                        ],
                      ),
                    ),
                  ],

                  // ── Add to Cart / Go to Cart Button ──────────────
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        if (inCart) {
                          // Already in cart → navigate to cart
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const CartScreen()),
                          );
                        } else {
                          // Add item(s) to cart
                          for (int i = 0; i < _localQty; i++) {
                            cart.addItem(widget.item);
                          }
                          _triggerFlyAnimation();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                  '${widget.item.name} added to cart!'),
                              backgroundColor: _orange,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                              action: SnackBarAction(
                                label: 'View Cart',
                                textColor: Colors.white,
                                onPressed: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => const CartScreen()),
                                ),
                              ),
                            ),
                          );
                        }
                      },
                      icon: Icon(
                        inCart
                            ? Icons.shopping_cart
                            : Icons.add_shopping_cart,
                        color: Colors.white,
                      ),
                      label: Text(
                        inCart ? 'Go to Cart' : 'Add to Cart',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _orange,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                        elevation: 2,
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CartQtyControl extends StatelessWidget {
  final int qty;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;

  const _CartQtyControl({
    required this.qty,
    required this.onDecrement,
    required this.onIncrement,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFE07B39),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: onDecrement,
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              child: Icon(Icons.remove, color: Colors.white, size: 16),
            ),
          ),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            transitionBuilder: (child, anim) =>
                ScaleTransition(scale: anim, child: child),
            child: Text(
              '$qty',
              key: ValueKey(qty),
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 15),
            ),
          ),
          GestureDetector(
            onTap: onIncrement,
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              child: Icon(Icons.add, color: Colors.white, size: 16),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// QUANTITY BUTTON  (bordered circle)
// ─────────────────────────────────────────────
class _QtyBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _QtyBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, size: 20),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// FLYING DOT ANIMATION
// ─────────────────────────────────────────────
class _FlyingDot extends StatefulWidget {
  final Offset startOffset;
  final Offset endOffset;
  final String imageUrl;
  final VoidCallback onComplete;

  const _FlyingDot({
    required this.startOffset,
    required this.endOffset,
    required this.imageUrl,
    required this.onComplete,
  });

  @override
  State<_FlyingDot> createState() => _FlyingDotState();
}

class _FlyingDotState extends State<_FlyingDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _progress;
  late Animation<double> _scale;
  late Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 750));

    _progress = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);

    _scale = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.3), weight: 15),
      TweenSequenceItem(tween: Tween(begin: 1.3, end: 0.35), weight: 85),
    ]).animate(_ctrl);

    _opacity = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.0), weight: 65),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 35),
    ]).animate(_ctrl);

    _ctrl.forward().whenComplete(widget.onComplete);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Offset _bezier(double t) {
    final s = widget.startOffset;
    final e = widget.endOffset;
    // Arc upward control point
    final c = Offset((s.dx + e.dx) / 2, s.dy - 140);
    final x = (1 - t) * (1 - t) * s.dx + 2 * (1 - t) * t * c.dx + t * t * e.dx;
    final y = (1 - t) * (1 - t) * s.dy + 2 * (1 - t) * t * c.dy + t * t * e.dy;
    return Offset(x, y);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) {
        final pos = _bezier(_progress.value);
        final size = 56.0 * _scale.value;
        return Positioned(
          left: pos.dx - size / 2,
          top: pos.dy - size / 2,
          child: Opacity(
            opacity: _opacity.value.clamp(0.0, 1.0),
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFE07B39).withOpacity(0.45),
                    blurRadius: 14,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: ClipOval(
                child: Image.network(
                  widget.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: const Color(0xFFE07B39),
                    child:
                        const Icon(Icons.fastfood, color: Colors.white, size: 24),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}