import SwiftUI

struct ActionBehaviorEditView: View {
	@Binding var switchInput: Bool
	@Binding var presetConfig: PresetConfig
	
	var body: some View {
		VStack(alignment: .leading, spacing: 0) {
			HStack {
				Text("Behavior")
					.font(.footnote)
				
				Spacer()
				
				Toggle("Switch Input", isOn: $switchInput)
			}
			.padding(.horizontal)
			
			PresetsView { presetConfig in
				CorePresetView(
					presetConfig: presetConfig,
					presetState: self.presetConfig == presetConfig ? .active(Color.green) : .inactive
				)
				.onTapGesture {
					self.presetConfig = presetConfig
				}
			}
		}
	}
}

// struct ActionBehaviorEditView_Previews: PreviewProvider {
//	static var previews: some View {
//		ActionBehaviorEditView(
//			switchInput: .constant(true),
//			presetConfig: .constant(<#T##value: PresetConfig##PresetConfig#>)
//		)
//	}
// }
