//
//  ThumbnailTitleSubtitleTableViewCell.swift
//  F1TV
//
//  Created by Noah Fetz on 25.10.20.
//

import UIKit
import Kingfisher

class ThumbnailTitleSubtitleTableViewCell: UITableViewCell, ImageLoadedProtocol {
    @IBOutlet weak var thumbnailImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var accessoryImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.thumbnailImageView.layer.cornerRadius = 5
        NotificationCenter.default.addObserver(self, selector: #selector(self.userInterfaceStyleChanged), name: .userInterfaceStyleChanged, object: nil)
    }
    
    func applyImage(imageInfo: ImageDto) {
        let url = URL(string: imageInfo.url)
        
        let processor = DownsamplingImageProcessor(size: self.thumbnailImageView.bounds.size)
        self.thumbnailImageView.kf.indicatorType = .activity
        self.thumbnailImageView.kf.setImage(
            with: url,
            options: [
                .processor(processor),
                .scaleFactor(UIScreen.main.scale),
                .transition(.fade(0.2)),
                .cacheOriginalImage
            ], completionHandler:
                {
                    result in
                    switch result {
                    case .success(let value):
                        print("Task done for: \(value.source.url?.absoluteString ?? "")")
                    case .failure(let error):
                        print("Job failed: \(error.localizedDescription)")
                    }
                })
    }
        
    @objc func userInterfaceStyleChanged() {
        if(ConstantsUtil.darkStyle) {
            if(self.isFocused) {
                self.titleLabel.textColor = .black
                self.subtitleLabel.textColor = .black
            }else{
                self.titleLabel.textColor = .white
                self.subtitleLabel.textColor = .white
            }
        }else{
            self.titleLabel.textColor = .black
            self.subtitleLabel.textColor = .black
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        self.userInterfaceStyleChanged()
    }
    
    func didLoadImage(image: ImageDto) {
        self.applyImage(imageInfo: image)
    }

    func loadImage(imageUrl: String) {
        if let imageInfo = DataManager.instance.images.first(where: {$0.uid == imageUrl.split(separator: "/").last ?? ""}) {
            self.applyImage(imageInfo: imageInfo)
        }else{
            DataManager.instance.loadImage(imageUrl: imageUrl, imageProtocol: self)
        }
    }
    
    func setAccessoryIcon(accessoryIcon: AccessoryIconType) {
        self.accessoryImageView.image = accessoryIcon.getIcon()
    }
}