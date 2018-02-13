;
(define (FU-remove-border inImage inDrawable
         pixels           ; grow / shrink size in pixels
         )
		 
  (gimp-image-undo-group-start inImage)
  
  (let* (
	 ;; (img (car (gimp-item-get-image inDrawable)))
         )
    
    ;;(gimp-context-set-sample-criterion SELECT_CRITERION_COMPOSITE)
    ;;(gimp-context-set-sample-threshold)
					; fuzzy select
    (gimp-image-select-contiguous-color inImage CHANNEL-OP-ADD inDrawable 1 1)
    
    (gimp-selection-grow inImage pixels)
    (gimp-selection-shrink inImage pixels)
    (gimp-layer-add-alpha inDrawable)
    (gimp-edit-cut inDrawable)
    (gimp-selection-all inImage)
    (gimp-selection-shrink inImage pixels)
    (gimp-selection-invert inImage)
    (gimp-edit-cut inDrawable)
    (gimp-selection-none inImage)
    (plug-in-autocrop RUN-NONINTERACTIVE inImage inDrawable)
    (gimp-image-undo-group-end inImage)
    (gimp-displays-flush)
    (list inImage inDrawable)    
    )
  )

(define (FU-remove-border-levels inImage inDrawable
         pixels           ; grow / shrink size in pixels
         )

  (let* (
	 (fn (string-append (car (gimp-image-get-filename inImage)) ".png"))
	 (theResult )
	 )
    (set! theResult (FU-remove-border inImage inDrawable pixels))
    (gimp-levels-stretch (cadr theResult) )
    theResult    
    )
  )

(define (act3-dng-to-artifacts
	 inDngFile            ; filename of input DNG
	 inDir            ; output File
         pixels           ; grow / shrink size in pixels
         )

  (let* ( ( inDng "none")
	  ( theDrawable )
	 (fn "")
	 (theResult )
	 )
    (set! inDng (car (file-ufraw-load RUN-NONINTERACTIVE inDngFile inDngFile) ) )
    (set! theDrawable  (car (gimp-image-get-active-drawable inDng) ) )
    (set! theResult (FU-remove-border-levels inDng theDrawable pixels))
    (set! fn (string-append inDir "/full.png"))
    (file-png-save-defaults RUN-NONINTERACTIVE (car theResult) (cadr theResult) fn fn)
    )
  )

					; Script registrations...

(script-fu-register "FU-remove-border"
		    "<Image>/Script-Fu/Act3/Remove Border"
		    "Do a fuzzy remove of the border"
		    "Quinn Hart <qjhart@ucdavis.edu>"
		    "Quinn Hart"
		    "5/27/2017"
		    "*"
		    SF-IMAGE 		"Input Image" 					0
		    SF-DRAWABLE 	"Input Drawable" 				0
		    SF-ADJUSTMENT 	"Grow / Shrink" 			'(10 0 100 1 10 0 1)
		    )


(script-fu-register "FU-remove-border-levels"
		    "<Image>/Script-Fu/Act3/Border & Levels"
		    "Remove Border, auto levels, save"
		    "Quinn Hart <qjhart@ucdavis.edu>"
		    "Quinn Hart"
		    "5/27/2017"
		    "*"
		    SF-IMAGE 		"Input Image" 	 0
		    SF-DRAWABLE 	"Input Drawable" 				0
		    SF-ADJUSTMENT 	"Grow / Shrink" 			'(10 0 100 1 10 0 1)
		    )

(script-fu-register "act3-dng-to-artifacts"
		    "<Image>/File/Act3/Menus/DNG to Artifacts"
		    "Read in Menu DNG file, save needed files"
		    "Quinn Hart <qjhart@ucdavis.edu>"
		    "Quinn Hart"
		    "5/27/2017"
		    ""
		    SF-FILENAME		"Input Menu DNG" 			""
		    SF-DIRNAME		"Output Directory for Menu Artifacts" 			""
		    SF-ADJUSTMENT 	"Grow / Shrink" 			'(10 0 100 1 10 0 1)
		    )
