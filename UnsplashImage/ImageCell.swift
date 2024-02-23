import Foundation
import UIKit

class ImageCell: UICollectionViewCell {
    private var isAnimationPerformed = false
    private lazy var imageView = UIImageView(frame: contentView.bounds)

    override init(frame: CGRect) {
        super.init(frame: frame)
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 5
        imageView.layer.borderWidth = 1
        imageView.layer.borderColor = UIColor.lightGray.cgColor
        imageView.clipsToBounds = true
        contentView.addSubview(imageView)
    }
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
    }
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func configure(image: UIImage) {
        imageView.image = image
    }
}
