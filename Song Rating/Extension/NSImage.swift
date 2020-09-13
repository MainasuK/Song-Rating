
import Cocoa

extension NSImage {
    /// https://gist.github.com/usagimaru/c0a03ef86b5829fb9976b650ec2f1bf4
    func withTintColor(_ tintColor: NSColor) -> NSImage {
        if self.isTemplate == false {
            return self
        }
        
        let image = self.copy() as! NSImage
        image.lockFocus()
        
        tintColor.set()
        
        let imageRect = NSRect(origin: .zero, size: image.size)
        imageRect.fill(using: .sourceAtop)
        
        image.unlockFocus()
        image.isTemplate = false
        
        return image
    }
}
