

//: # Path of intelligence
/*:
 Hi there, I am really happy to have your attention
 
 With the student challenge announced out of the blue, past days were quite intense, now I will go for a long walk outside and get a solid night of sleep.
 
 I hope that these few minutes ahead of you will be interesting enough to do some research about our defining body part, Brain!
 
 
 */

/*:
 ## Short description for busy people
 Because there are not many things that inspire me as much as this evolutionary masterpiece, I decided to create one.
 Although the basis of this project "class Brain" is fairly simple in how it works, it follows few fundamental rules.
 Truth is, if it was to follow all the biological processes, then: it would be highly desirable piece of technology :) and reaaaally power hungry.
 
 Currently,  one of the biggest brain emulation projects (Blue brain) uses "Blue gene" supercomputers to simulate the networks of neurons. Simulating 25 thousand simple neurons takes around 60 second on 22.8 TFLOPS processing unit.
 Maybe with a few optimizations, my i7 cpu would handle it as well :E
 
 */

import PlaygroundSupport
import UIKit

let brainVC = BrainViewController()
brainVC.view.frame = CGRect(x: 0, y: 0, width: 600, height: 600)

//Put on the live view, be aware, sometimes the liveView doesn't register clicks and needs to be reloaded
 PlaygroundSupport.PlaygroundPage.current.liveView = brainVC.view
//: End is defined by buttons appearing on the screen, but even after, don't stop tapping(clicking)

//: Buttons will enable you to quickly change chapters

/*:
 References:
 
 Eric R. Kandel, ed. (2006). Principles of neural science (5. ed.). Appleton and Lange: McGraw Hill. ISBN 978-0071390118.
 
 Nick Bostrom. Superintelligence
 
 Apple documentation: https://developer.apple.com/documentation/
 */
