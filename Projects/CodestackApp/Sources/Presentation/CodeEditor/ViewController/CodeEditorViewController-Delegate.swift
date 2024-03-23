
import UIKit
import SnapKit
import SafariServices

//MARK: TextView Size Tracker
extension CodeEditorViewController: TextViewSizeTracker {
    func updateNumberViewsHeight(_ height: CGFloat){
        ediotrContainer.numbersView.snp.updateConstraints { make in
            make.height.equalTo(height)
        }
    }
}

extension CodeEditorViewController: SFSafariViewControllerDelegate {
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        self.navigationController?.popViewController(animated: true)
    }
}


//MARK: - TextView delegate
extension CodeEditorViewController: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        return true
    }
}

extension CodeEditorViewController: NSLayoutManagerDelegate {
    func layoutManager(_ layoutManager: NSLayoutManager, paragraphSpacingAfterGlyphAt glyphIndex: Int, withProposedLineFragmentRect rect: CGRect) -> CGFloat {
        return 10
    }
}
