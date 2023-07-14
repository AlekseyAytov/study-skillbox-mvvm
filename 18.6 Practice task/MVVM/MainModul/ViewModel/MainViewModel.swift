//
//  MainPresenter.swift
//  18.6 Practice task
//
//  Created by Alex Aytov on 6/22/23.
//

import UIKit


protocol MainViewModelProtocol {
    init(networkService: NetworkServiceProtocol)
    func getSearchResults() -> [ResultForDisplay]
    func doSearch(searchExpression: String?, completion: ((Bool) -> Void)?)
    func getImage(for indexPath: IndexPath, completion: (() -> Void)?) -> UIImage?
}


class MainViewModel: MainViewModelProtocol {
    let networkService: NetworkServiceProtocol
    
    required init(networkService: NetworkServiceProtocol) {
        self.networkService = networkService
    }
    
    private var searchResults: [ResultForDisplay] = []
    // словарь для хранения изображений с измененными размерами
    private var resizeImagesCache: [IndexPath: UIImage] = [:]
        
    func getSearchResults() -> [ResultForDisplay] {
        return searchResults
    }
    
    // сервис API запроса
    func doSearch(searchExpression: String?, completion: ((Bool) -> Void)?) {
        // Обнуляем результаты предыдущего запроса
        searchResults = []
        resizeImagesCache = [:]
        
        networkService.getSearchResults(searchExpression: searchExpression) { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                switch result {
                case .success(let data):
                    // преобразование networkModel в массив структур ResultForDisplay
                    self.searchResults = Array(data.map{ResultForDisplay(networkModel: $0)})
                    completion?(true)
                case .failure(let error):
                    print(error.localizedDescription)
                    completion?(false)
                }
            }
        }
    }
    
    // метод возвращает картинку по ключу indexPath либо асинхронно её загружает и сохраняет в словарь,
    // при повторном использованиии метода возвращает загруженную картинку
    func getImage(for indexPath: IndexPath, completion: (() -> Void)?) -> UIImage? {
        if let image = resizeImagesCache[indexPath] {
            return image
        } else {
            // если изображения для текущего indexPath в словаре imagesCache нет, то загружаем изображение
            print("run service.loadImageAsync - \(indexPath)")
            networkService.loadImageAsync(urlString: searchResults[indexPath.row].image) { imageData in
                DispatchQueue.main.async {
                    if let imageData = imageData {
                        // если загрузка изображения произошла, то заносим в словарь
                        self.resizeImagesCache[indexPath] = UIImage(data: imageData)!.scalePreservingAspectRatio(targetSize: CGSize(width: 100, height: 100))
                    } else {
                        // если загрузка изображения НЕ произошла, то заносим в словарь No-Image-Placeholder
                        self.resizeImagesCache[indexPath] = UIImage(named: "No-Image-Placeholder")
                    }
                    
                    print("ended service.loadImageAsync - \(indexPath)")
                    completion?()
                }
            }
        }
        return nil
    }
}
