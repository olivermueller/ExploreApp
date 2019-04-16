# ExploreApp

An application that can recognise different types of safety signs; it offers an exploration mode where the user can discover safety signs and a quiz mode where the users are being quizzed about what they see.

# Overview
In order to build and run the app, you only need to install the latest version of <a href="https://developer.apple.com/xcode/">Xcode</a>. Once you install it make sure you open the ```.xcworkspace``` file, otherwise the dependencies will not be recognised.

The app is built on top of the <a href="https://developer.apple.com/documentation/vision/recognizing_objects_in_live_capture">object recognition example</a> provided by Apple which offers a basic setup for object recognition with an already trained model.

# Training a model

## Turicreate
The models in this project were trained using <a href = "https://github.com/apple/turicreate">turicreate</a>, a library designed for easy creation of CoreML models which can be used for training models to perform <a href = "https://towardsdatascience.com/image-classifier-cats-vs-dogs-with-convolutional-neural-networks-cnns-and-google-colabs-4e9af21ae7a8">image classification</a> as well as <a href = "https://pjreddie.com/darknet/yolo/">object detection</a>. A very good resource for getting started with training an object detection model with turicreate is <a href="https://github.com/apple/turicreate/tree/master/userguide/object_detection">this tutorial</a> since it gives a detailed step by step guide.

## Other
Even though turicreate is used for training in this project, you could use any other framework as long as you convert to a CoreML model at the end. This is relatively easy to do with the <a href= "https://developer.apple.com/documentation/coreml/converting_trained_models_to_core_ml">coremltools</a> library as long as you use one of their specified frameworks (Caffe v1, Keras 1.2.2+, scikit-learn 0.18, XGBoost 0.6, LIBSVM 3.22).

## Compatibility
In order to have your trained model compatible with this project, you will have to comply to the following restrictions:
  1. All the classes names will have to follow the <a href="https://www.iso.org/standard/54432.html">ISO standard</a> names (ISO_7010_####). The ```bobbyen.json``` file contains display information about each class as well as a ```key``` which represents the name of the class.
  2. The input for the model has to be a square image and the output has to be two ```MultiArrays``` of confidence and coordinates. More detailed information about the types can be found by opening Xcode and clicking one of the example models.

# Adding the model

1. Open the Xcode project
2. Drag and drop the ```mlmodel``` into the ```Models``` folder
3. Open ```Theme.swift```
4. In ```GetModel()``` function, change one of the models that is loaded.
  * You could replace ```onezeroninesignsv2().model``` with ``yourimportedmodel().model``
5. Build and run

**It is very important to have the class names match the name in the .json file! Otherwise, the app will not function properly. I you just want to quick test your model and make sure it works, I would definitely recommend using the <a href="https://developer.apple.com/documentation/vision/recognizing_objects_in_live_capture">object recognition example</a> from Apple; even though it misses the functionality this app has, it is still enough for testing different trained models.**
