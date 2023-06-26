//
//  DetailViewController.swift
//  18.6 Practice task
//
//  Created by Alex Aytov on 6/26/23.
//

import UIKit

class DetailViewController: UIViewController {
    
    var presenter: DetailViewPresenterProtocol!
    
    private lazy var image: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = .white
        imageView.contentMode = .scaleAspectFit
        // суть параметра completion в работе после загрузки картинки, если картинки нет
        imageView.image = presenter.getOrLoadImage(completion: { [weak self] in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.image.image = self.presenter.getOrLoadImage(completion: nil)
                imageView.setNeedsDisplay()
            }
        })
        return imageView
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = presenter.model.title
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    
    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.text = presenter.model.description
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupConstraints()
    }
    
    private func setupViews() {
        view.backgroundColor = .white
        view.addSubview(image)
        view.addSubview(titleLabel)
        view.addSubview(descriptionLabel)
    }
    
    private func setupConstraints() {
        image.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.topMargin)
            make.leading.trailing.equalToSuperview().inset(10)
            make.height.equalTo(400)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(image.snp.bottom).offset(20)
        }
        
        descriptionLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(titleLabel.snp.bottom).offset(20)
        }
    }
}
