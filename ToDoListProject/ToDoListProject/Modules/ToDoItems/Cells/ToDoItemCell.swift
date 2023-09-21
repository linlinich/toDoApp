//
//  ItemCell.swift
//  ToDoListProject
//
//  Created by Ангелина Решетникова on 21.06.2023.
//

import UIKit


protocol ToDoItemCellDelegate: AnyObject {
    func didTapDoneButton(indexPath: IndexPath)
}

class ToDoItemCell: UITableViewCell {
    
    enum Position {
        case solo
        case first
        case middle
        case last
    }
    
    private weak var delegate: ToDoItemCellDelegate?
    private var indexPath: IndexPath?
    var position: Position = .middle
    
    private let chevronImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "chevron.forward", withConfiguration: UIImage.SymbolConfiguration(pointSize: 16, weight: .bold))
        imageView.tintColor = UIColor(asset: Asset.Colors.gray)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let circleImageView: UIButton = {
        let imageView = UIButton()
        imageView.setBackgroundImage(UIImage(systemName: "circle"), for: .normal)
        imageView.tintColor = UIColor(asset: Asset.Colors.separator)
        imageView.backgroundColor = UIColor(asset: Asset.Colors.backSecondary)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 12
        imageView.addTarget(nil, action: #selector(didTapDoneButton), for: .touchUpInside)
        return imageView
    }()
    
    lazy var taskLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: Constans.TaskLabel.fontSize)
        label.numberOfLines = 3
        label.textColor = UIColor(asset: Asset.Colors.labelPrimary)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var deadlineLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: Constans.Deadline.fontSize)
        label.textColor = UIColor(asset: Asset.Colors.labelTertiary)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        addSubviews()
        makeStaticConstraints()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        addSubviews()
        makeStaticConstraints()
        circleImageView.isHidden = false
        chevronImageView.isHidden = false
        deadlineLabel.text = nil
        taskLabel.text = nil
        taskLabel.textColor = UIColor(asset: Asset.Colors.labelPrimary)
        taskLabel.attributedText = nil
        circleImageView.setBackgroundImage(UIImage(systemName: "circle"), for: .normal)
        circleImageView.tintColor = UIColor(asset: Asset.Colors.separator)
        circleImageView.backgroundColor = UIColor(asset: Asset.Colors.backSecondary)
    }

    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addSubviews() {
        contentView.addSubview(taskLabel)
        contentView.addSubview(chevronImageView)
        contentView.addSubview(circleImageView)
        contentView.addSubview(deadlineLabel)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setCorners()
    }
    
    func configure(data: TodoItem, delegate: ToDoItemCellDelegate, indexPath: IndexPath) {
        self.indexPath = indexPath
        self.delegate = delegate
        if data.didDone == true {
            circleImageView.setBackgroundImage(UIImage(systemName: "checkmark.circle.fill"), for: .normal)
            circleImageView.tintColor = UIColor(asset: Asset.Colors.green)
            circleImageView.backgroundColor = UIColor(asset: Asset.Colors.while)
            circleImageView.layer.cornerRadius = 20
            taskLabel.textColor = UIColor(asset: Asset.Colors.labelTertiary)
            let attributeString: NSMutableAttributedString = NSMutableAttributedString(string: data.text)
            attributeString.addAttribute(NSAttributedString.Key.strikethroughStyle,
                                         value: 1,
                                         range: NSRange(location: 0, length: attributeString.length))
            taskLabel.attributedText = attributeString
            return
        }
        
        if let deadline = data.deadline {
            let formatter = DateFormatter()
            if let localeID = Locale.preferredLanguages.first {
                formatter.locale = Locale(identifier: localeID)
            }
            formatter.dateFormat = "d MMMM"
            
            let symbolImage = UIImage(systemName: "calendar",
                                      withConfiguration: UIImage.SymbolConfiguration(pointSize: 14, weight: .regular))?
                                      .withTintColor(UIColor(asset: Asset.Colors.labelTertiary) ?? .red,
                                      renderingMode: .alwaysOriginal)
            let symbolAttachment = NSTextAttachment()
            symbolAttachment.image = symbolImage

            let attributedString = NSMutableAttributedString(attachment: symbolAttachment)
            attributedString.append(NSAttributedString(string: " " + formatter.string(from: deadline)))

            deadlineLabel.attributedText = attributedString
        } else {
        }
        
        if data.importance == ImportanceOfTask.important || data.importance == ImportanceOfTask.unimportant {
            
            let symbolImage: UIImage
            switch data.importance {
            case .important:
                symbolImage = UIImage(systemName: "exclamationmark.2",
                                      withConfiguration: UIImage.SymbolConfiguration(pointSize: Constans.TaskLabel.fontSize, weight: .bold))?
                                      .withTintColor(UIColor(asset: Asset.Colors.red) ?? .red,
                                      renderingMode: .alwaysOriginal) ?? UIImage()
                circleImageView.tintColor = UIColor(asset: Asset.Colors.red)
                let backgroundColor = UIColor(asset: Asset.Colors.redBackground)
                circleImageView.backgroundColor = backgroundColor
            case .unimportant:
                symbolImage = UIImage(systemName: "arrow.down",
                                      withConfiguration: UIImage.SymbolConfiguration(pointSize: 16, weight: .bold))?
                                      .withTintColor(UIColor(asset: Asset.Colors.gray) ?? .gray,
                                      renderingMode: .alwaysOriginal) ?? UIImage()
            case .usual:
                taskLabel.text = data.text
                return
            }
            
            let symbolAttachment = NSTextAttachment()
            symbolAttachment.image = symbolImage

            let attributedString = NSMutableAttributedString(attachment: symbolAttachment)
            attributedString.append(NSAttributedString(string: " " + data.text))
            attributedString.addAttribute(NSAttributedString.Key.strikethroughStyle,
                                          value: 0,
                                          range: NSRange(location: 0, length: attributedString.length))
            
            taskLabel.attributedText = attributedString
            return
        } else {
            let normalString = NSMutableAttributedString(string: data.text)
            normalString.addAttribute(NSAttributedString.Key.strikethroughStyle, value: 0, range: NSRange(location: 0, length: normalString.length))
            taskLabel.attributedText = normalString

        }
    }
    
    func configureNewCell() {
        let normalString = NSMutableAttributedString(string: "Новое")
        normalString.addAttribute(NSAttributedString.Key.strikethroughStyle, value: 0, range: NSRange(location: 0, length: normalString.length))
        taskLabel.attributedText = normalString
        taskLabel.textColor = UIColor(asset: Asset.Colors.labelTertiary)
        circleImageView.isHidden = true
        chevronImageView.isHidden = true
    }
    
    func setCorners() {
        let cornerRadius: CGFloat = Constans.cornerRadius
        switch position {
        case .solo: roundCorners(corners: .allCorners, radius: cornerRadius - 3)
        case .first: roundCorners(corners: [.topLeft, .topRight], radius: cornerRadius)
        case .last: roundCorners(corners: [.bottomLeft, .bottomRight], radius: cornerRadius)
        default: noCornerMask()
        }
    }
    
    func roundCorners(corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        layer.mask = mask
    }
    func noCornerMask() {
        layer.mask = nil
    }
    
    func makeStaticConstraints() {
        
        NSLayoutConstraint.activate([
            chevronImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constans.generalIndent),
            chevronImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            chevronImageView.heightAnchor.constraint(equalToConstant: Constans.ChevronImage.heaigh),
            chevronImageView.widthAnchor.constraint(equalToConstant: Constans.ChevronImage.width)
        ])
        
        NSLayoutConstraint.activate([
            circleImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constans.generalIndent),
            circleImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            circleImageView.heightAnchor.constraint(equalToConstant: Constans.CircleImage.side),
            circleImageView.widthAnchor.constraint(equalToConstant: Constans.CircleImage.side),
            
            taskLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            taskLabel.leadingAnchor.constraint(equalTo: circleImageView.trailingAnchor, constant: 12),
            taskLabel.trailingAnchor.constraint(equalTo: chevronImageView.leadingAnchor, constant: -16),
            
            deadlineLabel.topAnchor.constraint(equalTo: taskLabel.bottomAnchor),
            deadlineLabel.leadingAnchor.constraint(equalTo: taskLabel.leadingAnchor),
            deadlineLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12),
            deadlineLabel.widthAnchor.constraint(equalToConstant: 100)
        ])
    }
    
    @objc
    func didTapDoneButton() {
        guard let indexPath = indexPath else { return }
        delegate?.didTapDoneButton(indexPath: indexPath)
    }
    
}

extension ToDoItemCell {
    struct Constans {
        static let generalIndent: CGFloat = 16
        static let verticalIndetIfDeadlineSet: CGFloat = 12
        static let cornerRadius: CGFloat = 16

        struct ChevronImage {
            static let heaigh: CGFloat = 12
            static let width: CGFloat = 7
        }
        
        struct CircleImage {
            static let side: CGFloat = 24
        }
        
        struct TaskLabel {
            static let verticalIndentToCircle: CGFloat = 12
            static let fontSize: CGFloat = 17
        }
        
        struct Deadline {
            static let fontSize: CGFloat = 15
        }
    }
}

