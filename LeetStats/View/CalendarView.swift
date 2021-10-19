//
//  CalendarView.swift
//  LeetStats
//
//  Created by Roman Rakhlin on 11.10.2021.
//

import UIKit

class CalendarView: UIView {
    
    var calendarSubmissions: [String: Int]!
    var submissions: [Int]!
    
    //initWithFrame to init view from code
    init(frame: CGRect, data: [Int]!) {
        super.init(frame: frame)
        // set submissions array
        submissions = data
        
        // create UI components
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //common func to init our view
    private func setupView() {
        // round view
        self.layer.cornerRadius = self.frame.size.height / 5
        
        // shadows views
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOpacity = 0.4
        self.layer.shadowOffset = .zero
        self.layer.shadowRadius = 8
        
        // MARK: - work with main view style
        self.backgroundColor = UIColor(named: "CalendarColor") // color
        self.layer.cornerRadius = self.frame.size.height / 12 // round
        
        // little bit of shadows
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOpacity = 0.4
        self.layer.shadowOffset = .zero
        self.layer.shadowRadius = 8
        
        // MARK: - so here goes work with Calendar
        
        var indexInSubmission = 0
//        submissions = submissions.reversed() // reverse submission array
        print(submissions)

        // array to add in future in columnsStackView
        var columnStacks: [UIStackView] = []

        for columns in 1...12 {
            // array to add in future in columnStackView
            var columnViews: [UIView] = []

            for cell in 1...7 {
                let cellView = UIView(frame: CGRect(x: 0, y: 0, width: 24, height: 24))
                
                // here we setting color depends on value of submissions
                var cellColor: UIColor!
                let levelsOfColors: [String: UIColor] = [
                    "none": UIColor(named: "CalendarItemColor")!,
                    "begginer": UIColor(r: 178, g: 223, b: 71),
                    "intermediate": UIColor(r: 94, g: 199, b: 33),
                    "advanced": UIColor(r: 45, g: 100, b: 13)
                ]
                
                switch submissions[indexInSubmission] {
                case 1...5:
                    cellColor = levelsOfColors["begginer"]!
                case 6...15:
                    cellColor = levelsOfColors["intermediate"]!
                case 16...1000:
                    cellColor = levelsOfColors["advanced"]!
                default:
                    cellColor = levelsOfColors["none"]!
                }
                
                cellView.backgroundColor = cellColor
                
                // corner radius
                cellView.layer.cornerRadius = cellView.frame.size.height / 12 // round
                
                // little bit of shadows
                cellView.layer.shadowColor = UIColor.black.cgColor
                cellView.layer.shadowOpacity = 0.2
                cellView.layer.shadowOffset = .zero
                cellView.layer.shadowRadius = 4
                
                columnViews.append(cellView)
                
                indexInSubmission += 1
            }

            // create columnStackView and add all 7 views
            let columnStackView = UIStackView(arrangedSubviews: columnViews)
            columnStackView.axis = .vertical
            columnStackView.distribution = .fillEqually
            columnStackView.alignment = .fill
            columnStackView.spacing = 4

            columnStacks.append(columnStackView)
        }

        // create columnsStackView and add those 12 stacks
        let columnsStackView = UIStackView(arrangedSubviews: columnStacks)
        columnsStackView.axis = .horizontal
        columnsStackView.distribution = .fillEqually
        columnsStackView.alignment = .fill
        columnsStackView.spacing = 4
        columnsStackView.translatesAutoresizingMaskIntoConstraints = false
        
        self.addSubview(columnsStackView)
        
        // adding constraints for Main Stack
        let viewsDictionary = ["stackView":columnsStackView]
        let stackView_H = NSLayoutConstraint.constraints(withVisualFormat: "H:|-20-[stackView]-20-|", options: NSLayoutConstraint.FormatOptions(rawValue: 0), metrics: nil, views: viewsDictionary)
        let stackView_V = NSLayoutConstraint.constraints(withVisualFormat: "V:|-20-[stackView]-20-|", options: NSLayoutConstraint.FormatOptions(rawValue:0), metrics: nil, views: viewsDictionary)
        self.addConstraints(stackView_H)
        self.addConstraints(stackView_V)
    }
}

extension UIColor {
     convenience init(r: CGFloat,g:CGFloat,b:CGFloat,a:CGFloat = 1) {
         self.init(
             red: r / 255.0,
             green: g / 255.0,
             blue: b / 255.0,
             alpha: a
         )
     }
 }
