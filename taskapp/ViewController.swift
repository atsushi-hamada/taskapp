//
//  ViewController.swift
//  taskapp
//
//  Created by cpcadmin on 2024/02/29.
//

import UIKit
import UserNotifications
import RealmSwift

class ViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,UISearchBarDelegate {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    // Realmインスタンスを取得する
        let realm = try! Realm()

        // DB内のタスクが格納されるリスト。
        // 日付の近い順でソート：昇順
        // 以降内容をアップデートするとリスト内は自動的に更新される。
        var taskArray = try! Realm().objects(Task.self).sorted(byKeyPath: "date", ascending: true)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        tableView.fillerRowHeight = UITableView.automaticDimension
        tableView.delegate = self
        tableView.dataSource = self
        searchBar.delegate=self
    }
    // 入力画面から戻ってきた時に TableView を更新させる
       override func viewWillAppear(_ animated: Bool) {
           super.viewWillAppear(animated)
           tableView.reloadData()
       }
    
    // segue で画面遷移する時に呼ばれる
       override func prepare(for segue: UIStoryboardSegue, sender: Any?){
           let inputViewController:InputViewController = segue.destination as! InputViewController

           if segue.identifier == "cellSegue" {
               let indexPath = self.tableView.indexPathForSelectedRow
               inputViewController.task = taskArray[indexPath!.row]
           } else {
               inputViewController.task = Task()
           }
       }
    
    //データの数(セルの数)を返すメソッド
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return taskArray.count
    }
    
    //検索機能
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        taskArray = realm.objects(Task.self).where({ $0.category == searchText})
        tableView.reloadData()
       // print(filteredTask)
       // print(filteredTask.count)
    }
    
    
   
    
    
    //各セルの内容を返すメソッド
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //再利用可能なcellを得る
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        let task = taskArray[indexPath.row]
                cell.textLabel?.text = task.title

                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd HH:mm"

                let dateString:String = formatter.string(from: task.date)
                cell.detailTextLabel?.text = dateString
        
        return cell
    }
    //各セルを選択した時に実行されるメソッド
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "cellSegue", sender: nil)
    }
    
    //セルの削除が可能なことを伝えるメソッド
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    
    //deleteボタンが押された時に呼ばれるメソッド
    func tableView(_ tableView: UITableView, commit editingStyle : UITableViewCell.EditingStyle,forRowAt indexPath:IndexPath){
        if editingStyle == .delete {
                    // 削除するタスクを取得する
                    let task = self.taskArray[indexPath.row]

                    // ローカル通知をキャンセルする
                    let center = UNUserNotificationCenter.current()
                    center.removePendingNotificationRequests(withIdentifiers: [String(task.id.stringValue)])

                    // データベースから削除する
                    try! realm.write {
                        self.realm.delete(task)
                        tableView.deleteRows(at: [indexPath], with: .fade)
                    }

                    // 未通知のローカル通知一覧をログ出力
                    center.getPendingNotificationRequests { (requests: [UNNotificationRequest]) in
                        for request in requests {
                            print("/---------------")
                            print(request)
                            print("---------------/")
                        }
                    }
                }
    }

}

