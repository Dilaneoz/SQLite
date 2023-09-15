//
//  ViewController.swift
//  SqliteOrnek
//
//  Created by Dilan Öztürk on 12.03.2023.
//

import UIKit
import SQLite3

// SQLite verileri tek bir platformlar arası dosyada saklar. özel bir sunucu veya özel dosya sistemi olmadığından sqlite ı "dağıtmak" kitaplığını bağlamak ve yeni bir normal dosya oluşturmak kadar kolaydır. özetle sqlite uygulama içinde verilerimizi saklayabileceğimiz ufak bir database dir. bir dosyadır aslında ve içine kayıtlar eklenir.

// Realm açık kaynaklı veritabanı yönetim sistemidir. Realm veritabanı kullanımı kolay, sqlite veritabanına göre query oluşturma konusunda daha performanslı bir yapıya sahip. Realm, java swift objective-c javascript ve .net gibi birçok yazılıma da destek vermektedir. doğrudan telefonların tabletlerin içinde çalışan bir mobil veritabanıdır ve son derece zengin bir özellik setini korurken, genel işlemlerde sqlite tan bile daha hızlıdır

class ViewController: UIViewController,UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var kullaniciTableView: UITableView!
    @IBOutlet weak var txtAdi: UITextField!
    @IBOutlet weak var txtSoyadi: UITextField!
    var db : OpaquePointer?
    var kullaniciArray = [Kullanici]()
  
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let fileUrl = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create : false).appendingPathComponent("BilgeAdam.sqlite") // sqlite isimli bir veritabanı oluştur. sqlite uzantılı bir dosyayı uygulamam içerisinde FileManager class ını kullanarak bir documentDirectory ile beraber BilgeAdam.sqlite isimli bir veri tabanı oluştur
        
        if sqlite3_open(fileUrl.path, &db) != SQLITE_OK { // fileUrl dosyasını aç. db üzerinden bağlantı kuracak. & operatörü bir değişkeni başka bir değişkenin adresiyle eşitlemek istediğimizde kullanılır
            
            print("bağlantı açılamadı")
        }
        
        if sqlite3_exec(db, "CREATE TABLE IF NOT EXISTS Kullanici(Id INTEGER PRİMARY KEY AUTOINCREMENT, adi TEXT, soyadi TEXT)",nil,nil,nil) !=  SQLITE_OK {
            
            print("tablo oluşturulamadı") // bağlantı açıldıysa (yani yukarıdaki kodlar sorunsuz çalıştıysa bu kod çalışır), kullanıcı tablosu daha önce oluşturulmadıysa oluştur. id diye bir kolon olsun tipi int olsun, primary key olsun ve AUTOINCREMENT olsun (yani her kayıt eklendiğinde birer birer artsın), adi diye bir kolon olsun tipi text olsun, soyadi diye bir kolon olsun tipi text olsun
        }
    }
    
    @IBAction func btnKaydetAction(_ sender: Any) {
        
        let adi = txtAdi.text! // adının içindeki değeri al değişkene ata
        let soyadi = txtSoyadi.text!
        
        if (adi.isEmpty) { // adi değişkeni boş ise
            txtAdi.layer.borderWidth = 2.0
            txtAdi.layer.borderColor = UIColor.red.cgColor // çerçevenin etrafı kırmızı olacak
            return
        }
        if(soyadi.isEmpty) {
            txtSoyadi.layer.borderWidth = 2.0
            txtSoyadi.layer.borderColor = UIColor.red.cgColor
            return
        }
        
        var stmt : OpaquePointer? // sorgu işlemlerinden sorumlu
        let ekleSorgusu = "INSERT INTO Kullanici(adi,soyadi) values(?,?)" // ekleme işleme INSERT INTO ile yapılıyor. kullanıcı tablosuna adı soyadı kolonuna ekle. soru işaretleri döndürülecek parametreler için yer tutmuş olucak
        
        if sqlite3_prepare(db,ekleSorgusu,-1,&stmt,nil) != SQLITE_OK {
            print("kayıt eklenemedi")
            return
        }
        if sqlite3_bind_text (stmt,1,soyadi,-1,nil) != SQLITE_OK{ // sorguyu hazırlamakla ilgili bir sorun yoksa parametreleri ekle
            print("parametre  eklenemedi")
        }
        if sqlite3_bind_text (stmt,1,soyadi,-1,nil) != SQLITE_OK{ // kullanıcı tablosunun adi ve soyadi kolonuna gönderdiğimiz parametreler gelecek
            print("parametre  eklenemedi")
        }
        if sqlite3_step(stmt) != SQLITE_DONE{
            print("kayıt ekleme sırasında bir sorun oluştu")
            return
        }
        print("kayıt başarılı")
        txtAdi.text = "" // kayıt eklendikten sonra text in içini temizle
        txtSoyadi.text = ""
        
        self.KayitGetir()
    }
    
    func KayitGetir () {
        
        let sorgu = "select * from Kullanici" // kullanıcı tablosu için bana kayıtları getir
        var stmt : OpaquePointer? // statement dediğimiz, sorgularımızda parametre gönderme işlerinden sorumlu OpaquePointer denilen bir değişken oluşturuyoruz
        if sqlite3_prepare(db, sorgu, -1, &stmt, nil) != SQLITE_OK { // database den yukarıda yazmış olduğumuz sorgu yu çalıştır ve ordan bize stmt ile beraber bir sorgu getir ve bir sorgu sonucundan bir sorun yoksa (!= SQLITE_OK), kaydı işlemeye başla
            
            print("kayıtlar gelmedi")
            return
        }
        while(sqlite3_step(stmt) == SQLITE_ROW) // kayıtlar geldiyse, bunları bir while döngüsüyle işliyoruz. while döngüsüyle gelen kayıt sayısı kadar stmt objesiyle beraber sırayla bir işlemden geçecek
        {
            let id = sqlite3_column_int(stmt,0) // 0. kolondaki değeri al bana getir
            let adi = String(cString : sqlite3_column_text(stmt,1)) // 1. kolondaki değeri al bana getir
            let soyadi = String(cString : sqlite3_column_text(stmt,2)) // 2. kolondaki değeri al bana getir
            
            kullaniciArray.append( Kullanici(Id: Int(id), Adi: adi, Soyadi: soyadi)) // her oluşturduğumuz değişkenlerden de içinde Kullanıcı tipinde veri alan bir array tanımlıyoruz. o array in içine de ekleyecek
        }
        self.kullaniciTableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.kullaniciArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = kullaniciTableView.dequeueReusableCell(withIdentifier: "cell") as! CustomTableViewCell
        let kullanici : Kullanici
        kullanici = self.kullaniciArray[indexPath.row]
        cell.lblAdi.text = kullanici.Adi
        cell.lblSoyadi.text = kullanici.Soyadi
        return cell 
    }
}
