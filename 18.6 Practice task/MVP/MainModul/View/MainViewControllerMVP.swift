//
//  MainViewControllerMVP.swift
//  18.6 Practice task
//
//  Created by Alex Aytov on 6/23/23.
//

import UIKit

class MainViewControllerMVP: UIViewController {
    
    var presenter: MainViewPresenterProtocol!
    
    private var reuseCellIdentifier = "standartCell"
    
    private lazy var mainTableView: UITableView = {
        let table = UITableView()
        table.dataSource = self
        table.delegate = self
        return table
    }()
    
    private lazy var mainSearchBar: UISearchBar  = {
        let searchBar = UISearchBar()
        searchBar.delegate = self
        searchBar.placeholder = Constants.Titles.placeholder
        return searchBar
    }()
    
    private lazy var aboutInfo: UILabel = {
        let label = UILabel()
        label.text = Constants.Titles.info
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    
    private lazy var activityIndicator: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
        return view
    }()

    private func setupViews() {
        view.backgroundColor = .white
        view.addSubview(mainTableView)
        view.addSubview(mainSearchBar)
        view.addSubview(aboutInfo)
        mainSearchBar.addSubview(activityIndicator)
    }
    
    private func setupConstraints() {
        aboutInfo.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.topMargin)
            make.bottom.equalTo(mainSearchBar.snp.top)
            make.leading.trailing.equalToSuperview().inset(20)
        }
        
        mainSearchBar.snp.makeConstraints { make in
            make.bottom.equalTo(mainTableView.snp.top)
            make.leading.trailing.equalToSuperview()
        }
        
        mainTableView.snp.makeConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottomMargin)
            make.leading.trailing.equalToSuperview()
        }
        
        activityIndicator.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.centerX.equalTo(mainSearchBar.searchTextField.snp.leading).inset(17)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupConstraints()
    }
}

// MARK: - TableView DataSource

extension MainViewControllerMVP: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        presenter.getNumberOfRows(for: section)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var reuseCell = tableView.dequeueReusableCell(withIdentifier: reuseCellIdentifier) ?? UITableViewCell()
        configure(cell: &reuseCell, for: indexPath)
        return reuseCell
    }
    
    private func configure(cell: inout UITableViewCell, for indexPath: IndexPath) {
        guard let result = presenter.getSearchResult(for: indexPath) else { return }
        
        var configuration = cell.defaultContentConfiguration()
        configuration.text = "\(result.title)"
        configuration.secondaryText = "\(result.description)"
        
        let image = presenter.getOrLoadImage(for: indexPath) {
            DispatchQueue.main.async {
                // для отображения изображения перезагружаем ячейку
                print("mainTableView.reloadRows - \(indexPath)")
                self.mainTableView.reloadRows(at: [indexPath], with: .none)
            }
        }
        configuration.image = image

        // установка максимального размера картинки в ячейке
        var imageProperties = configuration.imageProperties
        imageProperties.maximumSize = CGSize(width: 100, height: 100)
        configuration.imageProperties = imageProperties
        
        cell.contentConfiguration = configuration
    }
}
// MARK: - TableView Delegate

extension MainViewControllerMVP: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let detailVC = DetailViewController()
        let detailVCPresenter = DetailViewPresenter(about: presenter.getSearchResult(for: indexPath)!)
        detailVC.presenter = detailVCPresenter
        self.navigationController?.pushViewController(detailVC, animated: true)
    }
}

// MARK: - SearchBar Delegate

extension MainViewControllerMVP: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        print("searchBarSearchButtonClicked")
        activityIndicator.startAnimating()
        // прячем левую вью searchTextField для отображения activityIndicator
        mainSearchBar.searchTextField.leftView?.isHidden = true
        // скрываем клавиатуру после нажатия
        searchBar.resignFirstResponder()
        
        presenter.makeSearch(searchExpression: searchBar.text) { [weak self] seccessFlag in
            if !seccessFlag {
                DispatchQueue.main.async {
                    guard let self = self else { return }
                    self.activityIndicator.stopAnimating()
                    self.mainSearchBar.searchTextField.leftView?.isHidden = false
                    print("An error occurred!")
                }
                return
            } else {
                DispatchQueue.main.async {
                    guard let self = self else { return }
                    print("mainTableView.reloadData()")
                    self.mainTableView.reloadData()
                    self.activityIndicator.stopAnimating()
                    self.mainSearchBar.searchTextField.leftView?.isHidden = false
                }
            }
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        print("searchBarCancelButtonClicked")
        searchBar.showsCancelButton = false
        searchBar.text = nil
        activityIndicator.stopAnimating()
        mainSearchBar.searchTextField.leftView?.isHidden = false
        searchBar.resignFirstResponder()
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = true
    }
}

