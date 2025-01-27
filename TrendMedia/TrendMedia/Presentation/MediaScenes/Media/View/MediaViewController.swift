//
//  ViewController.swift
//  TrendMedia
//
//  Created by meng on 2021/10/19.
//

import UIKit
import SnapKit

class MediaViewController: UIViewController {
    
    
    private let viewModel = MediaViewModel(dataManager: DataManager())
    private let headerView = UIView()
    
    private let videoButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "film"), for: .normal)
        button.tintColor = .green
        button.contentVerticalAlignment = .fill
        button.contentHorizontalAlignment = .fill
        button.imageView?.contentMode = .scaleAspectFit
        button.imageEdgeInsets = UIEdgeInsets(top: 30, left: 30, bottom: 30, right: 30)
        return button
    }()
    
    private let tvButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "tv"), for: .normal)
        button.contentVerticalAlignment = .fill
        button.contentHorizontalAlignment = .fill
        button.imageView?.contentMode = .scaleAspectFit
        button.imageEdgeInsets = UIEdgeInsets(top: 30, left: 30, bottom: 30, right: 30)
        button.tintColor = .orange
        return button

    }()
    
    private let bookButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "book.closed"), for: .normal)
        button.contentVerticalAlignment = .fill
        button.contentHorizontalAlignment = .fill
        button.imageView?.contentMode = .scaleAspectFit
        button.imageEdgeInsets = UIEdgeInsets(top: 30, left: 30, bottom: 30, right: 30)
        button.tintColor = .systemPink
        return button
    }()
    
    private lazy var categoryStackView: UIStackView = {
        let view = UIStackView(arrangedSubviews: [videoButton, tvButton, bookButton])
        view.distribution = .fillEqually
        view.setCornerShadow()
        view.backgroundColor = .white
        view.axis = .horizontal
        return view
    }()
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.showsVerticalScrollIndicator = false
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setView()
        attemptFetchMovie()
    }
    
    @objc private func menuBarButtonTap() {
        self.navigationItem.backButtonTitle = "뒤로" //백버튼 설정은 이전화면에서 설정
        let vc = MyMediaViewController()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc private func mapBarButtonTap() {
        let vc = MapViewController()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc private func searchBarButtonTap() {
        let vc = SearchViewController()
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true)
    }
    
    private func setView() {
        view.backgroundColor = .white
        setNavigationBar()
        addView()
        setConstraints()
        setTableView()
    }
    
    private func setNavigationBar() {
        self.title = "TREND MEDIA"
        let menuButton = UIBarButtonItem(image: UIImage(systemName: "list.dash"),
                                                                style: .plain,
                                                                target: self,
                                                                action: #selector(menuBarButtonTap))
        let mapButton = UIBarButtonItem(image: UIImage(systemName: "map"),
                                                                style: .plain,
                                                                target: self,
                                                                action: #selector(mapBarButtonTap))
        self.navigationItem.leftBarButtonItems = [menuButton, mapButton]
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .search,
                                                                 target: self,
                                                                 action: #selector(searchBarButtonTap))
        self.navigationItem.leftBarButtonItems?.forEach({ $0.tintColor = .black })
        self.navigationItem.rightBarButtonItem?.tintColor = .black
    }
    
    private func setTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(MediaCell.self, forCellReuseIdentifier: MediaCell.identifier)
    }
    
    private func addView() {
        view.addSubview(headerView)
        headerView.addSubview(categoryStackView)
        view.addSubview(tableView)
    }
    
    private func setConstraints() {
        headerView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.left.equalTo(view.safeAreaInsets.left)
            make.right.equalTo(view.safeAreaInsets.right)
            make.height.equalTo(view.bounds.height / 5)
        }
        categoryStackView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
            make.bottom.equalToSuperview().offset(-5)
            make.height.equalToSuperview().multipliedBy(0.7)
        }
        tableView.snp.makeConstraints { make in
            make.top.equalTo(headerView.snp.bottom)
            make.left.equalTo(view.safeAreaInsets.left)
            make.right.equalTo(view.safeAreaInsets.right)
            make.bottom.equalTo(view.safeAreaInsets.bottom)
        }
    }
}

extension MediaViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.tvShowListCount()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: MediaCell.identifier, for: indexPath) as? MediaCell else {
            return UITableViewCell()
        }
        if let value = viewModel.getTvShow(at: indexPath.row) {
            cell.updateUI(media: value)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 500
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.navigationItem.backButtonTitle = "뒤로" //백버튼 설정은 이전화면에서 설정
        let vc = ActorViewController()
        vc.mediaInfo = viewModel.getTvShow(at: indexPath.row)
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

extension MediaViewController {
    private func attemptFetchMovie() {
        
        //에러
        self.viewModel.codeAlertClosure = { [weak self] () in
            guard let strongSelf = self else { return }
            DispatchQueue.main.async {
                print("에러")
            }
        }
    
        self.viewModel.didFinishFetch = {
            DispatchQueue.main.async { [weak self] in
                guard let strongSelf = self else { return }
                strongSelf.tableView.reloadData()
            }
        }
        
        self.viewModel.requestFetchMovieData()
    }
}
