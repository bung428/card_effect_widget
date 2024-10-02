# Card effect Widget

# How to use
- asset image
````
CardHolographicWidget.asset({
    image: 'asssts/images/image.png',
    backImage: /// card back image
    touchCallback: (value) {
        /// todo callabck. 
        /// Callback for scrolling prevention, etc. during animation movement
    },
    sourceType: ImageSourceType.asset, // default value
    maxHeight: 360, // default value
    aspectRatio: 734 / 1024, // default value
    glare: , // optional
    filter: , // optional
    mask: , // optional
  })
````

- network image
````
CardHolographicWidget.network({
    image: 'Network image url',
    backImage: /// card back image
    touchCallback: (value) {
        /// todo callabck.
        /// Callback for scrolling prevention, etc. during animation movement
    },
    sourceType: ImageSourceType.network, // default value
    maxHeight: 360, // default value
    aspectRatio: 734 / 1024, // default value
    glare: , // optional
    filter: , // optional
    mask: , // optional
  })
````

# Configuration
1. Glare
   - GlareConfiguration.flash
   - GlareConfiguration.focus

2. Filter (FilterType) => cf. hue type is the degree, and other types except hue are between 0 ~ 1
   - contrast
   - grayScale
   - sepia
   - invert
   - hue
   - brightness
   - saturate
   - opacity
3. Mask