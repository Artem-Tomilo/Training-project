import UIKit

/*
 Протокол EmployeeEditViewControllerDelegate - интерфейс для взаимодействия с экраном Список сотрудников
 */

protocol EmployeeEditViewControllerDelegate: AnyObject {
    func addEmployeeDidCancel(_ controller: EmployeeEditViewController)
    func addNewEmployee(_ controller: EmployeeEditViewController, newEmployee: Employee)
    func editEmployee(_ controller: EmployeeEditViewController, newData: Employee, previousData: Employee)
}

/*
 EmployeeEditViewController - экран Редактирование сотрудника, отображает необходимые поля для введения нового, либо редактирования существующего сотрудника
 */

class EmployeeEditViewController: UIViewController, UITextFieldDelegate {
    
    private let surnameTextField = CustomTextField()
    private let nameTextField = CustomTextField()
    private let patronymicTextField = CustomTextField()
    private let positionTextField = CustomTextField()
    
    private var viewForIndicator = SpinnerView()
    
    private var saveButton = UIBarButtonItem()
    private var cancelButton = UIBarButtonItem()
    
    weak var delegate: EmployeeEditViewControllerDelegate?
    
    var employeeToEdit: Employee? // свойство, в которое будет записываться передаваемый сотрудник для редактирования
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        surnameTextField.becomeFirstResponder()
    }
    
    private func setup() {
        view.backgroundColor = .systemRed
        
        view.addSubview(surnameTextField)
        view.addSubview(nameTextField)
        view.addSubview(patronymicTextField)
        view.addSubview(positionTextField)
        
        surnameTextField.delegate = self
        nameTextField.delegate = self
        patronymicTextField.delegate = self
        positionTextField.delegate = self
        
        NSLayoutConstraint.activate([
            surnameTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            surnameTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 15),
            surnameTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -15),
            
            nameTextField.topAnchor.constraint(equalTo: surnameTextField.bottomAnchor, constant: 50),
            nameTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 15),
            nameTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -15),
            
            patronymicTextField.topAnchor.constraint(equalTo: nameTextField.bottomAnchor, constant: 50),
            patronymicTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 15),
            patronymicTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -15),
            
            positionTextField.topAnchor.constraint(equalTo: patronymicTextField.bottomAnchor, constant: 50),
            positionTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 15),
            positionTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -15),
        ])
        
        surnameTextField.placeholder = "Фамилия"
        nameTextField.placeholder = "Имя"
        patronymicTextField.placeholder = "Отчество"
        positionTextField.placeholder = "Должность"
        
        if let employeeToEdit = employeeToEdit {
            title = "Редактирование сотрудника"
            surnameTextField.text = employeeToEdit.surname
            nameTextField.text = employeeToEdit.name
            patronymicTextField.text = employeeToEdit.patronymic
            positionTextField.text = employeeToEdit.position
        } else {
            title = "Добавление сотрудника"
        }
        
        saveButton = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(saveEmployee(_:)))
        navigationItem.rightBarButtonItem = saveButton
        
        cancelButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancel(_:)))
        navigationItem.leftBarButtonItem = cancelButton
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(tapGestureTapped(_:)))
        view.addGestureRecognizer(gesture)
    }
    
    private func showSpinner() {
        viewForIndicator = SpinnerView(frame: self.view.bounds)
        view.addSubview(viewForIndicator)
        navigationController?.navigationBar.alpha = 0.3
    }
    
    /*
     saveEmployee - таргет на кнопку Save:
     сохраняет нового, либо отредактированного сотрудника, путем вызова необходимый методов через делегата и возвращает на экран Список сотрудников
     */
    
    @objc func saveEmployee(_ sender: UIBarButtonItem) {
        if let surname = surnameTextField.text,
           let name = nameTextField.text,
           let patronymic = patronymicTextField.text,
           let position = positionTextField.text {
            if var employee = employeeToEdit {
                employee.surname = surname
                employee.name = name
                employee.patronymic = patronymic
                employee.position = position
                showSpinner()
                delegate?.editEmployee(self, newData: employee, previousData: self.employeeToEdit!)
            } else {
                let employee = Employee(surname: surname, name: name, patronymic: patronymic, position: position)
                showSpinner()
                delegate?.addNewEmployee(self, newEmployee: employee)
            }
        }
    }
    
    /*
     таргет на кнопку Cancel - возвращает на предыдущий экран
     */
    
    @objc func cancel(_ sender: UIBarButtonItem) {
        delegate?.addEmployeeDidCancel(self)
    }
    
    /*
     таргет для UITapGestureRecognizer, который скрывает клавиатуру при нажатии на сводобное простарнство на экране
     */
    
    @objc func tapGestureTapped(_ sender: UITapGestureRecognizer) {
        guard sender.state == .ended else { return }
        view.endEditing(false)
    }
    
    /*
     таргет для кнопки done на клавиатуре - переходит на следующий textField, если он последний в списке, то прячет клавиатуру
     */
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case surnameTextField:
            nameTextField.becomeFirstResponder()
        case nameTextField:
            patronymicTextField.becomeFirstResponder()
        case patronymicTextField:
            positionTextField.becomeFirstResponder()
        case positionTextField:
            positionTextField.resignFirstResponder()
        default:
            break
        }
        return true
    }
}
