import UIKit

class ViewController: UIViewController {
    
    let videosController = ConferenceVideoController()
    static let titleElementKind = "title-element-kind"
    
    var collectionView: UICollectionView!
    
    var dataSource: UICollectionViewDiffableDataSource<ConferenceVideoController.VideoCollection, ConferenceVideoController.Video>!
    
    var currentSnapshot: NSDiffableDataSourceSnapshot
    <ConferenceVideoController.VideoCollection, ConferenceVideoController.Video>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Conference Videos"
        configureHierarchy()
        configureDataSource()
    }
    
    private func configureHierarchy() {
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .systemBackground
        
        view.addSubview(collectionView)
        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.topAnchor.constraint(equalTo: view.topAnchor)
        ])
        
        collectionView.register(ConferenceVideoCell.self, forCellWithReuseIdentifier: ConferenceVideoCell.reuseIdentifier)
        collectionView.register(TitleSupplementaryView.self, forSupplementaryViewOfKind: ViewController.titleElementKind, withReuseIdentifier: TitleSupplementaryView.reuseIdentifier)
    }
    
    private func configureDataSource() {
        dataSource = UICollectionViewDiffableDataSource(collectionView: collectionView) {
            (collectionView: UICollectionView, indexPath: IndexPath, video: ConferenceVideoController.Video) -> UICollectionViewCell? in
            
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ConferenceVideoCell.reuseIdentifier,
             for: indexPath) as? ConferenceVideoCell else {
                fatalError("Could not dequeue cell !")
            }
            
            cell.titleLabel.text = video.title
            cell.categoryLabel.text = video.category

            return cell
        }
        
        dataSource.supplementaryViewProvider = { [weak self]
            (collectionView: UICollectionView, kind: String, indexPath: IndexPath) -> UICollectionReusableView? in
            guard let self = self, let snapshot = self.currentSnapshot else { return nil }

            if let titleSupplementary = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: TitleSupplementaryView.reuseIdentifier,
                for: indexPath) as? TitleSupplementaryView {
                
                let videoCategory = snapshot.sectionIdentifiers[indexPath.section]
                titleSupplementary.label.text = videoCategory.title
                
                return titleSupplementary
            } else {
                fatalError("Cannot create new supplementary")
            }
        }
        
        currentSnapshot = NSDiffableDataSourceSnapshot<ConferenceVideoController.VideoCollection, ConferenceVideoController.Video>()
        videosController.collections.forEach {
            let collection = $0
            currentSnapshot.appendSections([collection])
            currentSnapshot.appendItems(collection.videos)
        }
        
        dataSource.apply(currentSnapshot, animatingDifferences: true)
    }
    
    private func createLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.8), heightDimension: .fractionalHeight(0.5))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.8),
                                              heightDimension: .absolute(380))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .continuousGroupLeadingBoundary
        section.interGroupSpacing = -30
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20)
        
        let titleSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                              heightDimension: .estimated(44))
        let titleSupplementary = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: titleSize,
            elementKind: ViewController.titleElementKind,
            alignment: .top)
        section.boundarySupplementaryItems = [titleSupplementary]
        
        let config = UICollectionViewCompositionalLayoutConfiguration()
        config.interSectionSpacing = -150
        
        let layout = UICollectionViewCompositionalLayout(section: section, configuration: config)
        
        return layout
    }
}



