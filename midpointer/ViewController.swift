import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var mainImageView: UIImageView!
    @IBOutlet weak var tempImageView: UIImageView!

    var lastPoint = CGPoint.zero
    var brushWidth: CGFloat = 2.0
    var opacity: CGFloat = 1.0
    var swiped = false

    var lineCoordinates: Array<Array<CGFloat>> = []

    let colors: [(CGFloat, CGFloat, CGFloat)] = [
            (0, 0, 0),
            (105.0 / 255.0, 105.0 / 255.0, 105.0 / 255.0),
            (1.0, 0, 0),
            (0, 0, 1.0),
            (51.0 / 255.0, 204.0 / 255.0, 1.0),
            (102.0 / 255.0, 204.0 / 255.0, 0),
            (102.0 / 255.0, 1.0, 0),
            (160.0 / 255.0, 82.0 / 255.0, 45.0 / 255.0),
            (1.0, 102.0 / 255.0, 0),
            (1.0, 1.0, 0),
            (1.0, 1.0, 1.0),
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        swiped = false
        if let touch = touches.first! as UITouch? {
            lastPoint = touch.locationInView(self.view)
        }
    }

    func drawLineFrom(fromPoint: CGPoint, toPoint: CGPoint) {
        UIGraphicsBeginImageContext(view.frame.size)
        let context = UIGraphicsGetCurrentContext()
        tempImageView.image?.drawInRect(CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height))

        CGContextMoveToPoint(context, fromPoint.x, fromPoint.y)
        CGContextAddLineToPoint(context, toPoint.x, toPoint.y)

        let coordinate: Array<CGFloat> = [toPoint.x, toPoint.y]
        lineCoordinates.append(coordinate)

        CGContextSetLineCap(context, CGLineCap.Round)
        CGContextSetLineWidth(context, brushWidth)
        CGContextSetRGBStrokeColor(context, 0, 0, 0, 1.0)
        CGContextSetBlendMode(context, CGBlendMode.Normal)

        CGContextStrokePath(context)

        tempImageView.image = UIGraphicsGetImageFromCurrentImageContext()
        tempImageView.alpha = opacity
        UIGraphicsEndImageContext()
    }

    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        swiped = true
        if let touch = touches.first! as UITouch? {
            let currentPoint = touch.locationInView(view)
            drawLineFrom(lastPoint, toPoint: currentPoint)

            lastPoint = currentPoint
        }
    }

    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if !swiped {
            // draw a single point
            drawLineFrom(lastPoint, toPoint: lastPoint)
        }

        // Merge tempImageView into mainImageView
        UIGraphicsBeginImageContext(mainImageView.frame.size)
        tempImageView.image?.drawInRect(CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height), blendMode: CGBlendMode.Normal, alpha: opacity)
        mainImageView.image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        tempImageView.image = nil

        drawMidpoint()
        lineCoordinates = []
    }

    func drawMidpoint() {
        var totalX: CGFloat = 0
        var totalY: CGFloat = 0

        for coordinate in lineCoordinates {
            totalX += coordinate[0]
            totalY += coordinate[1]
        }

        let midpointX = totalX / CGFloat(lineCoordinates.count)
        let midpointY = totalY / CGFloat(lineCoordinates.count)

        drawCircle(midpointX, y: midpointY)
    }

    func drawCircle(x: CGFloat, y: CGFloat) {
        let circlePath = UIBezierPath(arcCenter: CGPoint(x: x, y: y), radius: CGFloat(5), startAngle: CGFloat(0), endAngle: CGFloat(M_PI * 2), clockwise: true)

        let shapeLayer = CAShapeLayer()
        shapeLayer.path = circlePath.CGPath

        shapeLayer.fillColor = UIColor.redColor().CGColor
        shapeLayer.strokeColor = UIColor.redColor().CGColor
        shapeLayer.lineWidth = 3.0

        mainImageView.layer.sublayers = nil
        mainImageView.layer.addSublayer(shapeLayer)
    }
}
