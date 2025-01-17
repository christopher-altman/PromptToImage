//
//  SDMainWindowController.swift
//  PromptToImage
//
//  Created by hany on 05/12/22.
//

import Cocoa
import Quartz

func displayErrorAlert(txt:String) {
    let alert = NSAlert()
    alert.messageText = "Error"
    alert.informativeText = txt
    alert.runModal()
}

class SDMainWindowController: NSWindowController,
                              NSWindowDelegate,
                              NSSharingServicePickerDelegate,
                              NSSplitViewDelegate,
                              NSMenuDelegate,
                              NSTableViewDelegate {
    
    
    @IBOutlet weak var splitview: NSSplitView!
    
    @IBOutlet weak var imageview: IKImageView!
    @IBOutlet weak var stepsSlider: NSSlider!
    @IBOutlet weak var stepsLabel: NSTextField!
    @IBOutlet weak var indicator: NSProgressIndicator!
    @IBOutlet weak var indindicator: NSProgressIndicator!
    @IBOutlet weak var mainBtn: NSButton!
    @IBOutlet weak var promptView: NSTextField!
    @IBOutlet weak var negativePromptView: NSTextField!
    @IBOutlet weak var waitWin: NSWindow!
    @IBOutlet weak var waitProgr: NSProgressIndicator!
    @IBOutlet weak var waitLabel: NSTextField!
    @IBOutlet weak var waitInfoLabel: NSTextField!
    @IBOutlet weak var waitCULabel: NSTextField!
    @IBOutlet weak var unitsPopup: NSPopUpButton!
    @IBOutlet weak var progrWin: NSWindow!
    @IBOutlet weak var progrLabel: NSTextField!
    @IBOutlet weak var upscaleCheckBox: NSButton!
    @IBOutlet weak var saveBtn: NSButton!
    @IBOutlet weak var speedLabel: NSTextField!
    @IBOutlet weak var guidanceLabel: NSTextField!
    @IBOutlet weak var guidanceSlider: NSSlider!
    // img2img
    @IBOutlet weak var img2imgView: NSView!
    @IBOutlet weak var strengthSlider: NSSlider!
    @IBOutlet weak var str_clearBtn: NSButton!
    @IBOutlet weak var str_importBtn: NSButton!
    @IBOutlet weak var str_resizePopup: NSPopUpButton!
    @IBOutlet weak var str_label: NSTextField!
    @IBOutlet weak var strengthLabel: NSTextField!
    @IBOutlet weak var inputImageview: NSImageView!
    // images count
    @IBOutlet weak var imageCountSlider: NSSlider!
    @IBOutlet weak var imageCountStepper: NSStepper!
    @IBOutlet weak var imageCountLabel: NSTextField!
    // seed
    @IBOutlet weak var seedView: NSTextField!
    @IBOutlet weak var seedBtn: NSButton!
    @IBAction func switchSeedBtn(_ sender: NSButton) {
        self.seedView.isSelectable = sender.state == .off
        self.seedView.isEditable = sender.state == .off
    }
    // scheduler
    @IBOutlet weak var schedulerPopup: NSPopUpButton!
    // models
    @IBOutlet weak var modelsPopup: NSPopUpButton!
    
    // table view menu
    @IBOutlet weak var item_saveAllSelectedImages: NSMenuItem!
    
    // history
    @IBOutlet weak var historyTableView: NSTableView!
    @objc dynamic var history = [HistoryItem]()
    @IBOutlet var historyArrayController: NSArrayController!
    @IBOutlet weak var settings_keepHistoryBtn: NSButton!
    var currentHistoryItem : HistoryItem? = nil // used for sharing a single item from item's share btn
    
    // info popover
    var currentInfoPopoverItem : HistoryItem? = nil
    var infoPopover : NSPopover? = nil
    @IBOutlet var infoPopoverView: NSView!
    @IBOutlet weak var info_date: NSTextField!
    @IBOutlet weak var info_prompt: NSTextField!
    @IBOutlet weak var info_negativePrompt: NSTextField!
    @IBOutlet weak var info_seed: NSTextField!
    @IBOutlet weak var info_steps: NSTextField!
    @IBOutlet weak var info_guidance: NSTextField!
    @IBOutlet weak var info_inputImage: NSImageView!
    @IBOutlet weak var info_strength: NSTextField!
    @IBOutlet weak var info_size: NSTextField!
    @IBOutlet weak var info_upscaledsize: NSTextField!
    @IBOutlet weak var info_upscaledLabel: NSTextField!
    @IBOutlet weak var info_model: NSTextField!
    @IBOutlet weak var info_inputImageView: NSView!
    @IBOutlet weak var info_btn_copyStrength: NSButton!
    @IBOutlet weak var info_btn_copyInputImage: NSButton!
    @IBOutlet var info_upscaledView: NSView!
    @IBOutlet weak var info_upscaleBtn: NSButton!
    @IBOutlet weak var info_progress: NSProgressIndicator!
    
    // Settings
    @IBOutlet var settingsWindow: NSWindow!
    @IBOutlet weak var modelsPopupMenu: NSMenu!
    @IBOutlet weak var settings_selectDefaultCU: NSButton!
    @IBOutlet weak var settings_historyLimitLabel: NSTextField!
    @IBOutlet weak var settings_historyLimitStepper: NSStepper!
    @IBOutlet weak var settings_downloadBtn: NSButton!
    
    // Download model
    @IBOutlet var downloadWindow: NSWindow!
    @IBOutlet weak var downloadProgr: NSProgressIndicator!
    @IBOutlet weak var progressLabel: NSTextField!
    @IBOutlet weak var progressValueLabel: NSTextField!
    @IBOutlet weak var downloadButton: NSButton!
    
    // main info button (model card)
    @IBOutlet weak var modelCardBtn: NSButton!
    @IBAction func clickModelCardBtn(_ sender: Any) {
        if let name = currentModelRealName {
            let url = "https://huggingface.co/\(name)"
            if let url = URL(string: url) {
                NSWorkspace.shared.open(url)
            }
        }
    }
    
    // IKImageView
    var viewZoomFactor : CGFloat = 1
    var zoomToFit : Bool = true
    
    @IBOutlet weak var modelMainLabel: NSTextField!
    
    
    
    
    
    
    // MARK: Init
    
    convenience init(windowNibName:String, info:[String:AnyObject]?) {
        self.init(windowNibName: windowNibName)
        NSApplication.shared.activate(ignoringOtherApps: true)
        self.window?.makeKeyAndOrderFront(nil)
        self.window?.appearance = NSAppearance(named: .darkAqua)
    }
    
    
    
    // MARK: Did Load
    
    override func windowDidLoad() {
        super.windowDidLoad()
        self.setUnitsPopup()
        self.populateModelsPopup()
        self.readStoredControlsValues()
        //self.splitview.setPosition(297, ofDividerAt: 0)
        self.loadHistory()
        //
        self.imageview.hasVerticalScroller = true
        self.imageview.hasHorizontalScroller = true
        self.imageview.autohidesScrollers = false
    }
    
    
    
    
    // MARK: Will Close
    
    func windowWillClose(_ notification: Notification) {
        saveHistory()
        storeControlsValues()
    }
    
    
    // MARK: Enable/Disable IMG2IMG
    
    // display/hide img2img controls view according to pipeline parameter
    func enableImg2Img() {
        if let pipeline = sdPipeline {
            self.img2imgView.isHidden = !pipeline.canUseInputImage
            if !pipeline.canUseInputImage {
                self.inputImageview.image = nil
            }
        }
    }
    
    
    
    // MARK: Table View Delegate
    
    var imageProperties: NSDictionary = Dictionary<String, String>() as NSDictionary
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        if self.historyArrayController.selectedObjects.isEmpty {
            self.imageview.isHidden = true
        } else {
            let image = (self.historyArrayController.selectedObjects[0] as! HistoryItem).upscaledImage ?? (self.historyArrayController.selectedObjects[0] as! HistoryItem).image
            self.imageview.isHidden = false
            var viewRect = self.imageview.visibleRect as CGRect
            self.imageview.setImage(image.cgImage(forProposedRect: &viewRect, context: nil, hints: nil), imageProperties: [:])
           
            if self.zoomToFit {
                self.imageview.zoomImageToFit(self)
            } else {
                self.imageview.zoomFactor = viewZoomFactor
            }
        }
    }
    
    
    
    
    // MARK: Window Did Resize
    
    func windowDidResize(_ notification: Notification) {
        if self.zoomToFit { self.imageview.zoomImageToFit(self) }
    }
    
    
    @IBOutlet weak var led_cpu: NSImageView!
    @IBOutlet weak var led_gpu: NSImageView!
    @IBOutlet weak var led_ane: NSImageView!
    
    func setCUImages() {
        self.led_cpu.image = NSImage(named:"cpuon")!
        self.led_cpu.isEnabled = true
        switch currentComputeUnits {
        case .cpuAndGPU:
            self.led_gpu.image = NSImage(named:"gpuon")!
            self.led_gpu.isEnabled = true
            self.led_ane.image = NSImage(named:"aneoff")!
            self.led_ane.isEnabled = false
        case .cpuAndNeuralEngine:
            self.led_gpu.image = NSImage(named:"gpuoff")!
            self.led_gpu.isEnabled = false
            self.led_ane.image = NSImage(named:"aneon")!
            self.led_ane.isEnabled = true
        default:
            self.led_gpu.image = NSImage(named:"gpuon")!
            self.led_gpu.isEnabled = true
            self.led_ane.image = NSImage(named:"aneon")!
            self.led_ane.isEnabled = true
        }
    }
    
    func clearCUImages() {
        self.led_cpu.image = NSImage(named:"cpuoff")!
        self.led_cpu.isEnabled = false
        self.led_ane.image = NSImage(named:"aneoff")!
        self.led_ane.isEnabled = false
        self.led_gpu.image = NSImage(named:"gpuoff")!
        self.led_gpu.isEnabled = false
    }
    
    
    
    
}



var defaultImageViewZoom = 0










class SCUTableView : NSTableView {
    
    override func menu(for event: NSEvent) -> NSMenu? {
        let row = self.row(at: self.convert(event.locationInWindow, from: nil))
        if row != -1 {
            // click destro su record reale, decido cosa fare in base al numero di righe selezionate...
            
            if self.selectedRowIndexes.count <= 1 {
                // è attualmente selezionata una riga sola oppure nessuna riga
                // quindi forzo la selezione della riga sotto al click destro
                let iset = NSIndexSet(index: row)
                self.selectRowIndexes(iset as IndexSet, byExtendingSelection: false)
            } else {
                // sono attualmente selezionate più righe
                // non faccio nulla, poppo il menu dovunque sia il puntatore lasciando intatta la selezione
            }
            
        } else {
            
            // click destro su spazio vuoto quindi deseleziono tutto
            let iset = NSIndexSet()
            self.selectRowIndexes(iset as IndexSet, byExtendingSelection: false)
        }
        
        // in ogni caso poppo il menu bindato alla tableview
        return self.menu
        
    }
}
