import UIKit

class ViewController: UIViewController, UISearchBarDelegate {
    private let networkManager = NetworkManager.shared

    var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .white
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()

    var topConstraintSearchBar: NSLayoutConstraint!
    var textFromsearchBar: String = ""
    var resultImageArray: [UIImage] = []
    var imageDictForAnimation: [Int: Bool] = [:]

    private let errorLable: UILabel =  {
        let errorLable = UILabel()
        errorLable.textColor = .black
        errorLable.text = "К сожалению, поиск не дал результатов"
        errorLable.textAlignment = .left
        errorLable.translatesAutoresizingMaskIntoConstraints = false
        return errorLable
    }()

    private let searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        return searchBar
    }()
    private lazy var uiButton: UIButton = {
        let button = UIButton()
        button.setTitle("Искать", for: .normal)
        button.addTarget(self, action: #selector(buttonClicked), for: .touchUpInside)
        button.backgroundColor = UIColor(red: 255/255, green: 0/255, blue: 0/255, alpha: 100/100)
        button.layer.cornerRadius = 10
        button.translatesAutoresizingMaskIntoConstraints = false
        button.clipsToBounds = true
        return button
    }()

    private enum Const {
        static let buttomWidth: CGFloat = 82
        static let offset: CGFloat = 10
        static let buttomHeight: CGFloat = 48
    }

    private var activityIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView(style: .medium)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.color = .black
        return activityIndicator
    }()
    // MARK: Didload
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupSearchBar()
        setupCollectionView()
        setupConstraints(button: uiButton, searchBar: searchBar)
    }
    public func showErrorLabel() {
        activityIndicator.stopAnimating()
        errorLable.isHidden = false
    }

    @objc func buttonClicked() {
        resultImageArray.removeAll()
        NetworkManager.paginationCounter = 1
        imageDictForAnimation = [:]
        errorLable.isHidden = true
        activityIndicator.startAnimating()
        topConstraintSearchBar.constant = 50
        collectionView.reloadData()
        guard let searchText = searchBar.text else {
            return
        }
        fetchRequest(textFromsearchBar: searchText)
        print("поиск...")
    }

    // MARK: fetchRequest
    func fetchRequest(textFromsearchBar: String) {
        networkManager.loadDataUrls(searchRequest: textFromsearchBar) { [weak self]  result in
            guard let self = self else { return }

            switch result {
            case .success(let dataUrls):
                for urls in dataUrls.results {
                    let urlString = urls.urls.regular
                    guard let url = URL(string: urlString) else {
                        return
                    }

                    if let imageData = try? Data(contentsOf: url) {
                        if let image = UIImage(data: imageData) {
                            self.resultImageArray.append(image)
                            self.imageDictForAnimation[self.resultImageArray.count] = false
                            DispatchQueue.main.async {
                                self.activityIndicator.stopAnimating()
                                self.collectionView.reloadData()

                            }
                        }
                    }
                }
                if resultImageArray.count == 0 {
                    DispatchQueue.main.async {
                        self.errorLable.isHidden = false
                        self.collectionView.isHidden = true
                    }
                }

            case .failure(_):
                self.errorLable.isHidden = false
            }
        }
    }
}

// MARK: Setup constraint
extension ViewController {
    
    func setupSearchBar() {
        errorLable.isHidden = true
        
        if let searchBarTextField = searchBar.value(forKey: "searchField") as? UITextField {
            searchBarTextField.textColor = UIColor.black
        }
        searchBar.layer.borderColor = UIColor.white.cgColor
        searchBar.layer.borderWidth = 2
        searchBar.barTintColor = UIColor.white
        searchBar.delegate = self
        searchBar.placeholder = "Телефон, яблоки, груши"
    }
    
    func setupConstraints(button: UIButton, searchBar: UISearchBar) {
        view.addSubview(searchBar)
        view.addSubview(button)
        view.addSubview(collectionView)
        view.addSubview(activityIndicator)
        view.addSubview(errorLable)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        topConstraintSearchBar = searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 268)
        NSLayoutConstraint.activate([
            topConstraintSearchBar,
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Const.offset),
            searchBar.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor, constant: -Const.buttomWidth - 20),
            searchBar.heightAnchor.constraint(equalToConstant: Const.buttomHeight),
            uiButton.topAnchor.constraint(equalTo: searchBar.topAnchor),
            uiButton.heightAnchor.constraint(equalToConstant: Const.buttomHeight),
            uiButton.leadingAnchor.constraint(equalTo: searchBar.trailingAnchor, constant: 8),
            uiButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -Const.offset),
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            collectionView.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 16),
            collectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            collectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 16),
            errorLable.leadingAnchor.constraint(greaterThanOrEqualTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            errorLable.topAnchor.constraint(greaterThanOrEqualTo: view.safeAreaLayoutGuide.topAnchor, constant: 158),
        ])
    }
    // MARK: Setup CollectionView
    func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 5
        layout.minimumInteritemSpacing = 5
        let width = view.frame.size.width / 3.4
        collectionView.collectionViewLayout = layout
        layout.itemSize = CGSize(width: width, height: width)
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(ImageCell.self, forCellWithReuseIdentifier: "MyCell")
    }
}

// MARK: Setup Cell-collectionView
extension ViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        resultImageArray.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MyCell", for: indexPath) as? ImageCell {
            let imageString = resultImageArray[indexPath.row]
            cell.configure(image: imageString)
            return cell
        }
        return UICollectionViewCell()
    }

    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {

        if indexPath.item == resultImageArray.count - 1 {
            NetworkManager.paginationCounter += 1
            fetchRequest(textFromsearchBar: textFromsearchBar)
        }

        // MARK: Animation
        if imageDictForAnimation[indexPath.row] == false {
            cell.alpha = 0
            cell.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
            UIView.animate(withDuration: 0.5) {
                cell.alpha = 1
                cell.transform = CGAffineTransform.identity
            }
            imageDictForAnimation[indexPath.row] = true
        }
    }
    // MARK: present
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        let selectedImage = resultImageArray[indexPath.item]
        let imageViewController = UIViewController()
        let imageView = UIImageView(image: selectedImage)
        imageView.contentMode = .scaleAspectFit
        imageView.frame = imageViewController.view.bounds
        imageView.backgroundColor = .white
        imageView.isUserInteractionEnabled = true
        imageViewController.view.addSubview(imageView)

        if let presentationController = imageViewController.presentationController as? UISheetPresentationController {
            presentationController.detents = [
                .large()
            ]
            presentationController.prefersGrabberVisible = true
        }
        present(imageViewController, animated: true, completion: nil)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 1, right: 0)
    }
}
