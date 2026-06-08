import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import '../providers/menu_provider.dart';
import '../providers/wishlist_provider.dart';
import '../models/food_item.dart';
import 'cart_screen.dart';
import 'product_detail_screen.dart';

// ─────────────────────────────────────────────
// HOME SCREEN
// ─────────────────────────────────────────────
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const _orange = Color(0xFFE07B39);

  // GlobalKey to find the cart icon position for flying animation
  static final GlobalKey cartIconKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final menu = context.watch<MenuProvider>();
    final cart = context.watch<CartProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F3),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFF8F3),
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text('Deliver to',
                style: TextStyle(fontSize: 12, color: Colors.grey)),
            Row(
              children: [
                Icon(Icons.location_on, size: 16, color: Color(0xFFE07B39)),
                SizedBox(width: 4),
                Text('123, MG Road, Indore',
                    style:
                        TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
              ],
            ),
          ],
        ),
        actions: [
          Stack(
            children: [
              IconButton(
                key: cartIconKey, // <-- needed for flying animation target
                icon: const Icon(Icons.shopping_cart_outlined),
                onPressed: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const CartScreen())),
              ),
              if (cart.itemCount > 0)
                Positioned(
                  right: 6,
                  top: 6,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                        color: _orange, shape: BoxShape.circle),
                    child: Text(
                      '${cart.itemCount}',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Search Bar ──────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              onChanged: menu.setSearch,
              decoration: InputDecoration(
                hintText: 'Search for pizza, burger...',
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none),
              ),
            ),
          ),

          // ── Category Chips ───────────────────────────
          SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: menu.categories.length,
              itemBuilder: (context, i) {
                final cat = menu.categories[i];
                final selected = menu.selectedCategory == cat;
                return GestureDetector(
                  onTap: () => menu.setCategory(cat),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin:
                        const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: selected ? _orange : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withOpacity(0.06),
                            blurRadius: 4,
                            offset: const Offset(0, 2))
                      ],
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      cat,
                      style: TextStyle(
                          color: selected ? Colors.white : Colors.black87,
                          fontWeight: FontWeight.w500,
                          fontSize: 13),
                    ),
                  ),
                );
              },
            ),
          ),

          // ── Popular Items heading ────────────────────
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Text('Popular Items',
                style:
                    TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),

          // ── Food Cards ───────────────────────────────
          Expanded(
            child: menu.filteredItems.isEmpty
                ? const Center(child: Text('No items found'))
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    itemCount: menu.filteredItems.length,
                    itemBuilder: (context, i) {
                      return _FoodCard(
                        item: menu.filteredItems[i],
                        cartIconKey: cartIconKey,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// FOOD CARD  (with wishlist + qty controls + flying animation)
// ─────────────────────────────────────────────
class _FoodCard extends StatefulWidget {
  final FoodItem item;
  final GlobalKey cartIconKey;

  const _FoodCard({required this.item, required this.cartIconKey});

  @override
  State<_FoodCard> createState() => _FoodCardState();
}

class _FoodCardState extends State<_FoodCard> with TickerProviderStateMixin {
  // ── Flying dot animation ─────────────────────
  OverlayEntry? _overlayEntry;

  void _triggerFlyAnimation(BuildContext context) {
    // Find the food image position (this card's position)
    final RenderBox? cardBox = context.findRenderObject() as RenderBox?;
    final RenderBox? cartBox =
        widget.cartIconKey.currentContext?.findRenderObject() as RenderBox?;
    if (cardBox == null || cartBox == null) return;

    final cardPos = cardBox.localToGlobal(Offset.zero);
    final cartPos = cartBox.localToGlobal(Offset.zero);

    // Start = center of image thumbnail (left side of card, 55px down)
    final startOffset = Offset(cardPos.dx + 55, cardPos.dy + 55);
    // End = center of cart icon
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
    final qty = cart.quantityOf(widget.item.id);
    final isWishlisted = wishlist.isWishlisted(widget.item.id);

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => ProductDetailScreen(item: widget.item)),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.07),
                blurRadius: 8,
                offset: const Offset(0, 2))
          ],
        ),
        child: Row(
          children: [
            // ── Food Image ──────────────────────────
            ClipRRect(
              borderRadius:
                  const BorderRadius.horizontal(left: Radius.circular(16)),
              child: Image.network(
                widget.item.imageUrl,
                width: 110,
                height: 110,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: 110,
                  height: 110,
                  color: Colors.grey[200],
                  child: const Icon(Icons.fastfood, color: Colors.grey),
                ),
              ),
            ),

            // ── Details ─────────────────────────────
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 10, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name + Wishlist heart
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            widget.item.name,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 15),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        // ── WISHLIST BUTTON ──────────
                        GestureDetector(
                          onTap: () =>
                              wishlist.toggle(widget.item),
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            transitionBuilder: (child, anim) =>
                                ScaleTransition(scale: anim, child: child),
                            child: Icon(
                              isWishlisted
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              key: ValueKey(isWishlisted),
                              color: isWishlisted
                                  ? Colors.red
                                  : Colors.grey.shade400,
                              size: 22,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 4),

                    // Description
                    Text(
                      widget.item.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style:
                          const TextStyle(fontSize: 12, color: Colors.grey),
                    ),

                    const SizedBox(height: 6),

                    // Rating + Price + Cart control
                    Row(
                      children: [
                        const Icon(Icons.star,
                            size: 14, color: Color(0xFFE07B39)),
                        const SizedBox(width: 2),
                        Text('${widget.item.rating}',
                            style: const TextStyle(
                                fontSize: 12, fontWeight: FontWeight.w500)),
                        const SizedBox(width: 8),
                        Text(
                          '₹${widget.item.price.toInt()}',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: Color(0xFFE07B39)),
                        ),
                        const Spacer(),

                        // ── CART CONTROL ─────────────
                        // Shows "+" if not in cart, else shows "- qty +"
                        inCart
                            ? _InlineQtyControl(
                                qty: qty,
                                onDecrement: () =>
                                    cart.decrement(widget.item.id),
                                onIncrement: () {
                                  cart.increment(widget.item.id);
                                  _triggerFlyAnimation(context);
                                },
                              )
                            : _AddButton(onTap: () {
                                cart.addItem(widget.item);
                                _triggerFlyAnimation(context);
                              }),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// INLINE QUANTITY CONTROL  (- qty +)
// ─────────────────────────────────────────────
class _InlineQtyControl extends StatelessWidget {
  final int qty;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;

  const _InlineQtyControl({
    required this.qty,
    required this.onDecrement,
    required this.onIncrement,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: const Color(0xFFE07B39),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Minus button
          GestureDetector(
            onTap: onDecrement,
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              child: Icon(Icons.remove, color: Colors.white, size: 16),
            ),
          ),
          // Quantity
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
                  fontSize: 14),
            ),
          ),
          // Plus button
          GestureDetector(
            onTap: onIncrement,
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              child: Icon(Icons.add, color: Colors.white, size: 16),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// ADD BUTTON  (orange +)
// ─────────────────────────────────────────────
class _AddButton extends StatelessWidget {
  final VoidCallback onTap;
  const _AddButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: const Color(0xFFE07B39),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(Icons.add, color: Colors.white, size: 20),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// FLYING DOT ANIMATION  (image flies to cart)
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
        vsync: this, duration: const Duration(milliseconds: 700));

    _progress = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);

    _scale = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.2), weight: 20),
      TweenSequenceItem(tween: Tween(begin: 1.2, end: 0.4), weight: 80),
    ]).animate(_ctrl);

    _opacity = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.0), weight: 70),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 30),
    ]).animate(_ctrl);

    _ctrl.forward().whenComplete(widget.onComplete);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  // Bezier arc: goes up then curves to cart
  Offset _calcPosition(double t) {
    final start = widget.startOffset;
    final end = widget.endOffset;
    // Control point: midpoint lifted upward for arc effect
    final control = Offset(
      (start.dx + end.dx) / 2,
      start.dy - 120,
    );
    // Quadratic bezier
    final x = (1 - t) * (1 - t) * start.dx +
        2 * (1 - t) * t * control.dx +
        t * t * end.dx;
    final y = (1 - t) * (1 - t) * start.dy +
        2 * (1 - t) * t * control.dy +
        t * t * end.dy;
    return Offset(x, y);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) {
        final pos = _calcPosition(_progress.value);
        final size = 48.0 * _scale.value;
        return Positioned(
          left: pos.dx - size / 2,
          top: pos.dy - size / 2,
          child: Opacity(
            opacity: _opacity.value,
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFE07B39).withOpacity(0.4),
                    blurRadius: 12,
                    spreadRadius: 2,
                  )
                ],
              ),
              child: ClipOval(
                child: Image.network(
                  widget.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: const Color(0xFFE07B39),
                    child: const Icon(Icons.fastfood,
                        color: Colors.white, size: 20),
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