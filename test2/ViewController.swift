import UIKit
import FirebaseFirestore
import youtube_ios_player_helper

class ViewController: UIViewController, YTPlayerViewDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet weak var playerView: YTPlayerView!
    @IBOutlet weak var pickerView: UIPickerView!
    
    var categories = ["football", "food"]
    var selectedCategory: String?
    var videoIDs: [String] = []
    var selectedDocumentID: String?
    var remainingVideoIDs: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("Uygulama başlatıldı.")
        guard let playerView = playerView, let pickerView = pickerView else {
               fatalError("playerView veya pickerView nil")
           }
        
        playerView.delegate = self
        pickerView.delegate = self
        pickerView.dataSource = self
        
        pickerView.tintColor = .white

        selectedCategory = categories.first
        selectedDocumentID = "jeaZJhpLkT59OQaxRccT"
        loadVideoIDs()
    }
    
    func loadVideoIDs() {
        guard let category = selectedCategory else {
            print("Kategori seçilmemiş.")
            return
        }
        
        Task {
            await fetchVideoIDs(for: category) { [weak self] videoIDs in
                guard let self = self else { return }
                self.remainingVideoIDs = videoIDs
            }
        }
    }
    func fetchVideoIDs(for category: String, completion: @escaping ([String]) -> Void) async {
        guard let documentID = selectedDocumentID else {
            print("Document ID yok.")
            return
        }
        
        let db = Firestore.firestore()
        let collectionRef = db.collection("categories")
                              .document(documentID)
                              .collection(category)
        
        do {
            let querySnapshot = try await collectionRef.getDocuments()
            var videoIDs: [String] = []
            for document in querySnapshot.documents {
                if let videoID = document.data()["videoID"] as? String {
                    videoIDs.append(videoID)
                }
            }
            print("Fetched video IDs for \(category): \(videoIDs)")
            self.videoIDs = videoIDs
            completion(videoIDs)
        } catch {
            print("Error getting documents: \(error.localizedDescription)")
            completion([])
        }
    }
       
    @IBAction func playRandomVideo(_ sender: UIButton) {
        guard let category = selectedCategory else {
            print("Kategori seçilmemiş.")
            return
        }
        
        if remainingVideoIDs.isEmpty {
                   loadVideoIDs()
               }
               
               guard !remainingVideoIDs.isEmpty else {
                   print("Videolar bulunamadı.")
                   return
               }
               
               if let randomVideoID = remainingVideoIDs.randomElement() {
                   remainingVideoIDs.removeAll { $0 == randomVideoID }
                   playYouTubeVideo(videoID: randomVideoID)
               }
           }
           
           func playYouTubeVideo(videoID: String) {
               print("Playing video with ID: \(videoID)")
               playerView.load(withVideoId: videoID)
           }
           

           func numberOfComponents(in pickerView: UIPickerView) -> Int {
               return 1
           }
           

           func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
               return categories.count
           }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return categories[row]
    }

    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        return NSAttributedString(string: categories[row], attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
    }

           func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
               selectedCategory = categories[row]
               remainingVideoIDs = []
               loadVideoIDs()
           }
           func playerViewDidBecomeReady(_ playerView: YTPlayerView) {
               playerView.playVideo()
           }
           
           func playerView(_ playerView: YTPlayerView, receivedError error: YTPlayerError) {
               print("Oynatma hatası: \(error)")
           }
       }
