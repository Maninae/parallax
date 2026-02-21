import SwiftUI

/// A custom layout that arranges items in an organic, closely-packed spiral (Vogel's model)
/// This emulates the Apple Watch honeycomb/bubble layout in a natural way.
struct BubbleLayout: Layout {
    var itemSize: CGFloat
    var spacing: CGFloat
    
    // Scale factor dictates how tightly packed the spiral is based on the item area
    private var scaleFactor: Double {
        return Double((itemSize + spacing) * 0.6)
    }
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let count = subviews.count
        guard count > 0 else { return .zero }
        
        let (minX, maxX, minY, maxY) = calculateBounds(count: count)
        return CGSize(
            width: maxX - minX + itemSize + spacing * 2,
            height: maxY - minY + itemSize + spacing * 2
        )
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let count = subviews.count
        guard count > 0 else { return }
        
        let (minX, _, minY, _) = calculateBounds(count: count)
        
        // Offset to center the spiral within the layout canvas
        let offsetX = bounds.minX - minX + itemSize / 2 + spacing
        let offsetY = bounds.minY - minY + itemSize / 2 + spacing
        
        for (index, subview) in subviews.enumerated() {
            let pos = circularPosition(index: index + 1) // Start at 1 to avoid placing exactly at 0 if preferred, actually 0 is fine
            let adjustedPos = CGPoint(x: pos.x + offsetX, y: pos.y + offsetY)
            
            subview.place(
                at: adjustedPos,
                anchor: .center,
                proposal: ProposedViewSize(width: itemSize, height: itemSize)
            )
        }
    }
    
    // Generates coordinates using Vogel's formula for spiral distribution
    private func circularPosition(index: Int) -> CGPoint {
        let n = Double(index)
        let c = scaleFactor
        // 137.5 degrees converts to Golden Angle in radians
        let theta = n * 137.5 * .pi / 180.0
        let r = c * sqrt(n)
        
        return CGPoint(x: r * cos(theta), y: r * sin(theta))
    }
    
    private func calculateBounds(count: Int) -> (CGFloat, CGFloat, CGFloat, CGFloat) {
        var minX: CGFloat = 0, maxX: CGFloat = 0, minY: CGFloat = 0, maxY: CGFloat = 0
        for i in 0..<count {
            let pos = circularPosition(index: i)
            minX = min(minX, pos.x)
            maxX = max(maxX, pos.x)
            minY = min(minY, pos.y)
            maxY = max(maxY, pos.y)
        }
        return (minX, maxX, minY, maxY)
    }
}
