# Card Holographic Widget

# How to use
- asset image
````
CardHolographicWidget.asset({
    image: 'asssts/images/image.png',
    touchCallback: (value) {
        /// todo callabck.
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
    touchCallback: (value) {
        /// todo callabck.
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

2. Filter (FilterType)
   - contrast
   - grayScale
   - sepia
   - invert
   - hue (degree)
   - brightness
   - saturate
   - opacity
3. Mask