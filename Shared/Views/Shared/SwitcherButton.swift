import SwiftUI

struct SwitcherButton: View {
	var isOn: Bool
	var isTransitioning: Bool
	@State private var animatedOff: Bool = false
	
	var isActive: Bool {
		!animatedOff && (isOn || isTransitioning)
	}
	
	var shadowColor: Color {
		if isActive {
			return Color(#colorLiteral(red: 1, green: 0, blue: 0, alpha: 0.7))
		} else {
			return Color(white: 0, opacity: 0.3)
		}
	}
	
	var body: some View {
		ZStack {
			RoundedRectangle(cornerRadius: 4)
				.fill(RadialGradient(
					gradient: Gradient(colors: [
						Color(#colorLiteral(red: 0.4745098039, green: 0.4745098039, blue: 0.4745098039, alpha: 1)),
						Color(#colorLiteral(red: 0.720022738, green: 0.720022738, blue: 0.720022738, alpha: 1)),
					]),
					center: .center,
					startRadius: 10,
					endRadius: 70
				))
				.shadow(color: self.shadowColor, radius: 2)
			RoundedRectangle(cornerRadius: 4)
				.fill(RadialGradient(
					gradient: Gradient(colors: [
						Color(#colorLiteral(red: 1, green: 0, blue: 0, alpha: 1)),
						Color(#colorLiteral(red: 0.9960784314, green: 0.2745098039, blue: 0.3333333333, alpha: 1)),
					]),
					center: .center,
					startRadius: 10,
					endRadius: 70
				))
				.shadow(color: self.shadowColor, radius: 2)
				.opacity(isActive ? 1 : 0)
		}
		.onAppear {
			if self.isTransitioning {
				withAnimation(Animation.linear(duration: 0.2)
					.delay(0.2)
					.repeatForever(autoreverses: true)) {
					self.animatedOff = true
				}
			}
		}
		.frame(width: 50, height: 50)
	}
}

struct SwitcherButton_Previews: PreviewProvider {
	static var previews: some View {
		Group {
			SwitcherButton(isOn: false, isTransitioning: false)
				.padding()
			SwitcherButton(isOn: true, isTransitioning: false)
				.padding()
			SwitcherButton(isOn: false, isTransitioning: true)
				.padding()
		}
	}
}
