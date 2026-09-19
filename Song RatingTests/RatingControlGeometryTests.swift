//
//  RatingControlGeometryTests.swift
//  Song RatingTests
//
//  Geometry tests for the menu bar star rating control.
//
//  These assert the pure coordinate math rather than driving the UI, so every layout
//  variant is covered on any host OS — including the macOS 11…26 Big Sur layout, which
//  cannot otherwise be exercised on a macOS 27 machine.
//

import XCTest
@testable import Song_Rating

final class RatingControlGeometryTests: XCTestCase {

    // MARK: - Helpers

    private let starSize = NSSize(width: 16, height: 16)
    private let spacing: CGFloat = 4

    /// Width of the drawn stars image: 5 stars + 6 gaps.
    private var imageWidth: CGFloat { 5 * starSize.width + 6 * spacing }   // 104

    /// Star `i` spans `4 + 20i … 20 + 20i` in image coordinates.
    private func starMin(_ i: Int) -> CGFloat { spacing * CGFloat(1 + i) + starSize.width * CGFloat(i) }
    private func starMax(_ i: Int) -> CGFloat { starMin(i) + starSize.width }
    private func starCenter(_ i: Int) -> CGFloat { 0.5 * (starMin(i) + starMax(i)) }

    /// Resolve a point given in *image* coordinates by converting it to button coords.
    private func rating(atImageX imageX: CGFloat,
                        buttonWidth: CGFloat,
                        layout: RatingControl.Layout,
                        behavior: RatingControl.Behavior,
                        legacyInset: CGFloat = 0) -> Int? {
        let origin = layout.imageOriginX(buttonWidth: buttonWidth,
                                         imageWidth: imageWidth,
                                         legacyInset: legacyInset)
        return RatingControl.starRating(at: CGPoint(x: origin + imageX, y: 8),
                                        buttonWidth: buttonWidth,
                                        imageWidth: imageWidth,
                                        starSize: starSize,
                                        spacing: spacing,
                                        behavior: behavior,
                                        layout: layout,
                                        legacyInset: legacyInset)
    }

    // MARK: - Image origin per layout

    func testImageOriginForModernLayoutIsCentred() {
        // macOS 27+: no container inset; the image is centred in the button.
        XCTAssertEqual(RatingControl.Layout.modern.imageOriginX(buttonWidth: 112, imageWidth: imageWidth), 4)
        XCTAssertEqual(RatingControl.Layout.modern.imageOriginX(buttonWidth: 114, imageWidth: imageWidth), 5)
    }

    func testImageOriginForBigSurLayoutAddsContainerInset() {
        // macOS 11…26: the legacy container inset is added ahead of the centred image.
        XCTAssertEqual(
            RatingControl.Layout.bigSur(inset: 10).imageOriginX(buttonWidth: 112, imageWidth: imageWidth, legacyInset: 10),
            14
        )
        XCTAssertEqual(
            RatingControl.Layout.bigSur(inset: 20).imageOriginX(buttonWidth: 112, imageWidth: imageWidth, legacyInset: 20),
            24
        )
    }

    func testImageOriginForPreBigSurLayoutIsCentred() {
        XCTAssertEqual(RatingControl.Layout.preBigSur.imageOriginX(buttonWidth: 112, imageWidth: imageWidth), 4)
    }

    // MARK: - Clicking each star (full stars)

    func testEachStarResolvesWhenClickedAtItsCentre() {
        for i in 0..<5 {
            let rating = self.rating(atImageX: starCenter(i), buttonWidth: 112, layout: .modern, behavior: .full)
            XCTAssertEqual(rating, 2 * (i + 1), "clicking star \(i + 1) should give full stars")
        }
    }

    func testFullBehaviourNeverReturnsHalfStars() {
        for buttonWidth in stride(from: CGFloat(104), through: 140, by: 2) {
            for step in 0...208 {
                let imageX = CGFloat(step) * 0.5
                guard let rating = self.rating(atImageX: imageX, buttonWidth: buttonWidth, layout: .modern, behavior: .full) else {
                    continue
                }
                XCTAssertEqual(rating % 2, 0, "full behaviour produced a half star at imageX=\(imageX)")
            }
        }
    }

    // MARK: - Half stars

    func testLeftHalfOfEachStarGivesHalfStarAndRightHalfGivesFullStar() {
        for i in 0..<5 {
            // Midpoint of the star's left half, and of its right half.
            let left = self.rating(atImageX: 0.5 * (starMin(i) + starCenter(i)),
                                   buttonWidth: 112, layout: .modern, behavior: .both)
            let right = self.rating(atImageX: 0.5 * (starCenter(i) + starMax(i)),
                                    buttonWidth: 112, layout: .modern, behavior: .both)
            XCTAssertEqual(left, 2 * (i + 1) - 1, "left half of star \(i + 1) should be a half star")
            XCTAssertEqual(right, 2 * (i + 1), "right half of star \(i + 1) should be a full star")
        }
    }

    func testHalfBehaviourAlwaysGivesHalfStarWithinAStar() {
        for i in 0..<5 {
            let rating = self.rating(atImageX: starCenter(i), buttonWidth: 112, layout: .modern, behavior: .half)
            XCTAssertEqual(rating, 2 * (i + 1) - 1, "half behaviour should be a half star on star \(i + 1)")
        }
    }

    /// All ten increments must be reachable by sweeping the image left to right.
    func testSweepReachesEveryHalfStarIncrement() {
        var seen = Set<Int>()
        for step in 0...208 {
            let imageX = CGFloat(step) * 0.5
            if let rating = self.rating(atImageX: imageX, buttonWidth: 112, layout: .modern, behavior: .both) {
                seen.insert(rating)
            }
        }
        XCTAssertEqual(seen, Set(0...10), "dragging across the image should reach every half-star step")
    }

    // MARK: - Out of bounds

    func testDraggingLeftOfTheFirstStarClearsTheRating() {
        let rating = self.rating(atImageX: starMin(0) - 1, buttonWidth: 112, layout: .modern, behavior: .full)
        XCTAssertEqual(rating, 0)
    }

    func testDraggingFarLeftOfTheButtonClearsTheRating() {
        let rating = self.rating(atImageX: -80, buttonWidth: 112, layout: .modern, behavior: .full)
        XCTAssertEqual(rating, 0)
    }

    func testDraggingRightOfTheLastStarGivesFiveStars() {
        let rating = self.rating(atImageX: starMax(4) + 1, buttonWidth: 112, layout: .modern, behavior: .full)
        XCTAssertEqual(rating, 10)
    }

    func testDraggingFarRightOfTheButtonGivesFiveStars() {
        let rating = self.rating(atImageX: 200, buttonWidth: 112, layout: .modern, behavior: .full)
        XCTAssertEqual(rating, 10)
    }

    // MARK: - Star edges

    /// Regression: a point exactly on a star edge used to fall through every interval
    /// and resolve to `nil`, silently swallowing the click.
    func testPointsOnStarEdgesStillResolve() {
        for i in 0..<5 {
            for edge in [starMin(i), starMax(i)] {
                let rating = self.rating(atImageX: edge, buttonWidth: 112, layout: .modern, behavior: .full)
                XCTAssertNotNil(rating, "image x=\(edge) (edge of star \(i + 1)) should resolve")
            }
        }
    }

    /// The gaps between stars (`4pt` wide) resolve to `nil` by design: the point is not
    /// on a star. Callers treat `nil` as "no change", which is what keeps a drag stable
    /// while the cursor crosses a gap. Only the gaps may be `nil` — never a star itself.
    func testOnlyTheGapsBetweenStarsAreUnresolved() {
        for step in 0...208 {
            let imageX = CGFloat(step) * 0.5
            let rating = self.rating(atImageX: imageX, buttonWidth: 112, layout: .modern, behavior: .full)
            
            let inAGap = (0..<4).contains { imageX > starMax($0) && imageX < starMin($0 + 1) }
            if inAGap {
                XCTAssertNil(rating, "image x=\(imageX) is in a gap and should not resolve")
            } else {
                XCTAssertNotNil(rating, "image x=\(imageX) is on a star and must resolve")
            }
        }
    }

    /// A drag that crosses a gap keeps the previous rating rather than jumping to 0,
    /// because `nil` means "leave the rating alone".
    func testGapKeepsPreviousRatingWhenDragging() {
        // Just inside star 2, then just outside star 1: the gap point must not resolve,
        // so the caller retains the star-2 rating.
        let onStar = self.rating(atImageX: starMin(1) + 1, buttonWidth: 112, layout: .modern, behavior: .full)
        XCTAssertEqual(onStar, 4, "a point just inside star 2 should give 2 stars")

        let inGap = self.rating(atImageX: 0.5 * (starMax(0) + starMin(1)), buttonWidth: 112, layout: .modern, behavior: .full)
        XCTAssertNil(inGap, "the gap point should not resolve, leaving the rating unchanged")
    }

    // MARK: - Half-star behaviour in detail

    /// Half-star mode must produce every value from 0 to 10 (0, 0.5, 1 … 5 stars),
    /// and each increment must be produced by exactly one contiguous region.
    func testHalfStarModeProducesEveryIncrementInOrder() {
        var boundaries: [(imageX: CGFloat, rating: Int)] = []
        var previous: Int?
        for step in 0...208 {
            let imageX = CGFloat(step) * 0.5
            guard let rating = self.rating(atImageX: imageX, buttonWidth: 112, layout: .modern, behavior: .both) else { continue }
            if rating != previous {
                boundaries.append((imageX, rating))
                previous = rating
            }
        }
        XCTAssertEqual(boundaries.map(\.rating), Array(0...10),
                       "sweeping the image should step through every half-star increment exactly once")
        XCTAssertEqual(boundaries.first?.rating, 0)
        XCTAssertEqual(boundaries.last?.rating, 10)
    }

    /// Half-star thresholds sit at each star's midpoint: left half → half star,
    /// right half → full star.
    func testHalfStarThresholdIsAtStarMidpoint() {
        for i in 0..<5 {
            let justLeft = self.rating(atImageX: starCenter(i) - 0.5, buttonWidth: 112, layout: .modern, behavior: .both)
            let exactlyAt = self.rating(atImageX: starCenter(i), buttonWidth: 112, layout: .modern, behavior: .both)
            let justRight = self.rating(atImageX: starCenter(i) + 0.5, buttonWidth: 112, layout: .modern, behavior: .both)

            XCTAssertEqual(justLeft, 2 * (i + 1) - 1, "just left of star \(i + 1) midpoint should be a half star")
            XCTAssertEqual(exactlyAt, 2 * (i + 1) - 1, "the midpoint itself should still be a half star")
            XCTAssertEqual(justRight, 2 * (i + 1), "just right of star \(i + 1) midpoint should be a full star")
        }
    }

    /// Half-star mode must reach all eleven ratings, on every layout.
    func testHalfStarModeWorksOnEveryLayout() {
        let layouts: [(RatingControl.Layout, CGFloat)] = [
            (.preBigSur, 0), (.modern, 0), (.bigSur(inset: 10), 10), (.bigSur(inset: 20), 20),
        ]
        for (layout, inset) in layouts {
            var seen = Set<Int>()
            for step in 0...208 {
                let imageX = CGFloat(step) * 0.5
                if let rating = self.rating(atImageX: imageX, buttonWidth: 112, layout: layout,
                                            behavior: .both, legacyInset: inset) {
                    seen.insert(rating)
                }
            }
            XCTAssertEqual(seen, Set(0...10), "\(layout) should reach every half-star increment")
        }
    }

    /// Half-star mode must still clamp at both ends.
    func testHalfStarModeClampsOutOfBounds() {
        XCTAssertEqual(self.rating(atImageX: -50, buttonWidth: 112, layout: .modern, behavior: .both), 0)
        XCTAssertEqual(self.rating(atImageX: 250, buttonWidth: 112, layout: .modern, behavior: .both), 10)
    }

    /// The `.half` behaviour pins to the half star anywhere within a star, which is what
    /// the double-click shortcut uses.
    func testHalfBehaviourStaysHalfAcrossWholeStar() {
        for i in 0..<5 {
            for imageX in [starMin(i) + 0.5, starCenter(i), starMax(i) - 0.5] {
                XCTAssertEqual(self.rating(atImageX: imageX, buttonWidth: 112, layout: .modern, behavior: .half),
                               2 * (i + 1) - 1,
                               "half behaviour should be constant across star \(i + 1)")
            }
        }
    }

    // MARK: - Layout independence

    /// The same click position must map to the same star whichever layout is in play,
    /// because `imageOriginX` compensates for the container inset.
    func testAllLayoutsAgreeForClickAtStarCentre() {
        let layouts: [RatingControl.Layout] = [.preBigSur, .modern, .bigSur(inset: 10), .bigSur(inset: 20)]
        for layout in layouts {
            for i in 0..<5 {
                let inset: CGFloat
                if case .bigSur(let value) = layout { inset = value } else { inset = 0 }
                // On Big Sur the image really is inset further right, so the button
                // coordinate of the star centre shifts by the same amount.
                let origin = layout.imageOriginX(buttonWidth: 112, imageWidth: imageWidth, legacyInset: inset)
                let rating = RatingControl.starRating(at: CGPoint(x: origin + starCenter(i), y: 8),
                                                      buttonWidth: 112,
                                                      imageWidth: imageWidth,
                                                      starSize: starSize,
                                                      spacing: spacing,
                                                      behavior: .full,
                                                      layout: layout,
                                                      legacyInset: inset)
                XCTAssertEqual(rating, 2 * (i + 1), "\(layout) should resolve star \(i + 1)")
            }
        }
    }

    // MARK: - Degenerate input

    func testZeroSizedInputsResolveToNil() {
        XCTAssertNil(RatingControl.starRating(at: .zero,
                                              buttonWidth: 0,
                                              imageWidth: imageWidth,
                                              starSize: starSize,
                                              spacing: spacing,
                                              behavior: .full,
                                              layout: .modern))
        XCTAssertNil(RatingControl.starRating(at: .zero,
                                              buttonWidth: 112,
                                              imageWidth: 0,
                                              starSize: starSize,
                                              spacing: spacing,
                                              behavior: .full,
                                              layout: .modern))
    }
}
