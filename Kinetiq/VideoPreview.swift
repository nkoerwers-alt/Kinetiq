
import SwiftUI
import AVKit
import AVFoundation

struct VideoPreview: View {
    let url: URL

    @State private var player: AVPlayer
    @State private var isPlaying = false

    init(url: URL) {
        self.url = url
        _player = State(initialValue: AVPlayer(url: url))
    }

    var body: some View {
        VStack(spacing: 10) {
            VideoPlayer(player: player)
                .aspectRatio(16 / 9, contentMode: .fit)
                .clipShape(RoundedRectangle(cornerRadius: 10))

            HStack(spacing: 16) {
                Button {
                    player.seek(to: .zero)
                    player.play()
                    isPlaying = true
                } label: {
                    Image(systemName: "backward.end.fill")
                }

                Button {
                    if isPlaying {
                        player.pause()
                    } else {
                        player.play()
                    }
                    isPlaying.toggle()
                } label: {
                    Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                        .font(.system(size: 17, weight: .semibold))
                }

                Spacer()

                Text(isPlaying ? "Playing" : "Ready")
                    .font(.system(size: 12))
                    .foregroundStyle(.secondary)
            }
            .buttonStyle(.plain)
        }
        .onDisappear {
            player.pause()
            isPlaying = false
        }
        .onChange(of: url) { _, newURL in
            player.replaceCurrentItem(with: AVPlayerItem(url: newURL))
            isPlaying = false
        }
    }
}
