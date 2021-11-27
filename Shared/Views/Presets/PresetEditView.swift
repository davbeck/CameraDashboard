import SwiftUI
import CoreData

struct PresetEditView: View {
	@ObservedObject var presetConfig: PresetConfig
	var client: VISCAClient
	
	@State var isLoading: Bool = false
	@State var error: Swift.Error?
	
	var body: some View {
		VStack(alignment: .leading) {
			HStack {
				Text("Name:")
					.column("label", alignment: .trailing)
				TextField("(Optional)", text: $presetConfig.name)
			}
			HStack {
				Text("Color:")
					.column("label", alignment: .trailing)
				
				PresetColorPicker(presetColor: $presetConfig.color)
			}
			
			HStack {
				Spacer()
				Button {
					client.set(presetConfig.preset)
				} label: {
					Text("Set to Current Position")
				}
			}
		}
		.foregroundColor(Color.primary)
		.columnGuide()
		.padding()
		.disabled(isLoading)
		.alert($error)
		.onDisappear {
			try? presetConfig.managedObjectContext?.saveOrRollback()
		}
	}
}

// struct PresetEditView_Previews: PreviewProvider {
//	static var previews: some View {
//		_PresetEditView(presetConfig: .constant(PresetConfig()))
//	}
// }
