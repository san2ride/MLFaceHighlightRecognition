//
//  FaceHighlightView.swift
//  FaceHighlightRecognition
//
//  Created by Cause  I'm Electric on 3/5/24.
//

import SwiftUI
import Vision

struct FaceHighlightView: View {
    let photos = ["face","ball","bird", "friends-sitting", "people-sitting"]
    
    @State private var currentIndex: Int = 0
    @State private var classificationLabel: String = ""
    
    @State private var currentImage: UIImage?
    
    let placeHolderImage = UIImage(named: "placeholder")!
    
    private func detectFaces(completion: @escaping ([VNFaceObservation]?) -> Void) {
        
        guard let image = UIImage(named: photos[currentIndex]),
            let cgImage = image.cgImage,
            let orientation = CGImagePropertyOrientation(rawValue: UInt32(image.imageOrientation.rawValue))
        else {
            return completion(nil)
        }

        let request = VNDetectFaceRectanglesRequest()
        
        let handler = VNImageRequestHandler(cgImage: cgImage, orientation: orientation, options: [:])
        
        DispatchQueue.global().async {
            try? handler.perform([request])
            
            guard let observations = request.results else {
                return completion(nil)
            }
            completion(observations)
        }
    }
    
    var body: some View {
        VStack {
           
            Image(uiImage: currentImage ?? placeHolderImage)
            
            .resizable()
                .frame(width: 200, height: 200)
            HStack {
                Button("Previous") {
                    
                    if self.currentIndex >= self.photos.count {
                        self.currentIndex = self.currentIndex - 1
                    } else {
                        self.currentIndex = 0
                    }
                    
                    self.currentImage = UIImage(named: self.photos[self.currentIndex])!
                    
                    }.padding()
                    .foregroundColor(Color.white)
                    .background(Color.gray)
                    .cornerRadius(10)
                    .frame(width: 100)
                
                Button("Next") {
                    if self.currentIndex < self.photos.count - 1 {
                        self.currentIndex = self.currentIndex + 1
                    } else {
                        self.currentIndex = 0
                    }
                    
                    self.currentImage = UIImage(named: self.photos[self.currentIndex])!
                }
                .padding()
                .foregroundColor(Color.white)
                .frame(width: 100)
                .background(Color.gray)
                .cornerRadius(10)
            }.padding()
            
            Button("Classify") {
                self.detectFaces { results in
                    if let results = results {
                        if let currentImage = self.currentImage {
                            // draw rectangles
                            self.currentImage =
                            currentImage.drawOnImage(observations: results)
                        }
                        DispatchQueue.main.async {
                            self.classificationLabel = "Faces: \(results.count)"
                        }
                    }
                }
            }.padding()
            .foregroundColor(Color.white)
            .background(Color.green)
            .cornerRadius(8)
            
            Text("\(classificationLabel)")
        }
        .onAppear {
            // set the image
            self.currentImage = UIImage(named: self.photos[self.currentIndex])
        }
    }
}

#Preview {
    FaceHighlightView()
}
