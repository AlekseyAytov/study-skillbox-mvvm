//
//  DetailViewPresenter.swift
//  18.6 Practice task
//
//  Created by Alex Aytov on 6/26/23.
//
import UIKit

protocol DetailViewPresenterProtocol {
    init(about data: ResultForDisplay)
    var model: ResultForDisplay { get }
    func getOrLoadImage(completion: (() -> Void)?) -> UIImage?
}


class DetailViewPresenter: DetailViewPresenterProtocol {
    private var dataModel: ResultForDisplay
    private var image: UIImage?
    
    required init(about data: ResultForDisplay) {
        self.dataModel = data
    }

    var model: ResultForDisplay {
        dataModel
    }
    
    // метод возвращает картинку либо асинхронно её загружает и сохраняет в переменную,
    // при повторном использованиии метода возвращает загруженную картинку
    func getOrLoadImage(completion: (() -> Void)?) -> UIImage? {
        // если свойство self.image не null, то вернуть self.image
        if let image = self.image {
            return image
        // eсли свойство self.image null, то инициировать загрузку image по URL
        } else {
            guard let url = URL(string: model.imageURLString) else {
                // если константа url == nul, то self.image = картинка-плейсхолдер
                self.setPlaceholderImage()
                // вернуть картинку-плейсхолдер
                return self.image
            }
            // если константа url != nul, то запустить асинхронно загрузку картинки
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                guard let self = self else { return }
                print("run service.loadImageAsync")

                guard let contentOfURL = try? Data(contentsOf: url) else {
                    print("Ошибка, не удалось загрузить изображение")
                    // self.image = картинка-плейсхолдер
                    self.setPlaceholderImage()
                    completion?()
                    return
                }
                
                guard let loadedImage = UIImage(data: contentOfURL) else {
                    self.setPlaceholderImage()
                    completion?()
                    return
                }
                // если загрузка изображения произошла, то устанвливаем в качесте значения свойства self.image
                self.image = loadedImage
                completion?()
                print("ended service.loadImageAsync")
            }
        }
        return self.image
    }
    
    private func setPlaceholderImage() {
        self.image = UIImage(named: "No-Image-Placeholder")
    }
}
