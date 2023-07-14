//
//  DetailViewPresenter.swift
//  18.6 Practice task
//
//  Created by Alex Aytov on 6/26/23.
//
import UIKit

protocol DetailViewModelProtocol {
    init(networkService: NetworkServiceProtocol, result: ResultForDisplay)
    func getImage(completion: (() -> Void)?) -> UIImage?
    func getResult() -> ResultForDisplay
}

class DetailViewModel: DetailViewModelProtocol {
    private var result: ResultForDisplay
    var networkService: NetworkServiceProtocol

    required init(networkService: NetworkServiceProtocol, result: ResultForDisplay) {
        self.result = result
        self.networkService = networkService
    }

    private var image: UIImage?

    func getResult() -> ResultForDisplay {
        return result
    }

    // метод возвращает картинку либо асинхронно её загружает и сохраняет в переменную,
    // при повторном использованиии метода возвращает загруженную картинку
    func getImage(completion: (() -> Void)?) -> UIImage? {
        if let image = self.image {
            return image
        } else {
            guard let urlString = self.result.image else {
                self.setPlaceholderImage()
                return self.image
            }
            print(urlString)

            networkService.loadImageAsync(urlString: urlString) { imageData in
                DispatchQueue.main.async {
                    if let imageData = imageData {
                        self.image = UIImage(data: imageData)
                    } else {
                        self.setPlaceholderImage()
                    }
                    completion?()
                }
            }
        }
        return self.image
    }

    private func setPlaceholderImage() {
        self.image = UIImage(named: "No-Image-Placeholder")
    }
}
