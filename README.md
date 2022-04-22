# data-music

This repository contains the [MEI](http://music-encoding.org/)-encodings of the music sources of the [Freischütz Digital](http://freischuetz-digital.de) project.

## Introduction
In order to handle the desired complexity of information, *Freischütz Digital* came up with an [MEI](http://music-encoding.org/)-based data setup called **Core model**. The intention is to separate substantial musical information from the mere graphic appearance of the music manuscripts and sources – if one source uses some kind of visual shortcut to abbreviate the very same musical content that another source has written out, there is no *substantial* difference between these sources. Accordingly, our encodings should not be bloated by capturing graphical details of limited musical meaning. As MEI uses [TEI](http://tei-c.org/)'s concept of *parallel segmentation* for encoding variation between multiple sources, the use of `<app>` and `<rdg>` can make an encoding unmanageable quite easily. 
At the same time, *Freischütz Digital* is specifically interested in preserving information about the scripture of the sources. This results in a conflict of interests. One extreme would be to encode *all* differences using `<app>` and `<rdg>` in one single file, no matter how hard it would be to maintain and process this file. The other extreme would be to encode all musical sources separately, and then use external pointers etc. to identify *relevant* similarities and differences from the outside. It should be clear that this setup becomes equally complex when used to store the same amount of information. 
*Freischütz Digital* seeks a compromise between both approaches, effectively separating substantial musical content from it's graphical presentation in the manuscripts and prints. Admittedly, this model is also very complex, but ultimately, the complexity of a data model will always have to match the complexity of the contents that are to be encoded by this model.

## The Core Model
The basic idea of *Freischütz Digital*'s data model is to put the **musical content** of all considered sources into 
one shared file, which serves as **core** of the whole model. If sources differ in *pitches*, *durations*, *slurs* and similar substantial information, this variation is encoded in the **core** using *parallel segmentation* with `<app>` and `<rdg>`. This file does not contain any layout-related details like information about abbreviations and scribal shortcuts ("*colla parte*" etc.) or stem directions.
Besides the **core**, there is an additional file for each **source** which duplicates the complete document tree from the core, this time only containing the variants relevant to this particular source (that is, there are no `<app>` and `<rdg>` elements in these files, but only the reading from the respective source). Each `<note>` (and all other musical events as well) has no substantial information, so there are no `@dur`, `@pname`, `@oct` etc. attributes. Instead, these elements just provide graphical information (like `@stem.dir` on `<note>` or `@curvedir` on `<slur>`). Additionally, every single element points to its counterpart in the **core** file using a `@sameas` relation. In order to fully understand an element in the **sources**, a user has to follow its `@sameas` pointer to the **core** and copy in all other attributes provided there. This means *you can look at the musical content by processing just the **core***, but *you need to process both the **core** and the **souce** file to get the full encoding of a source*.
For convenience, this repository contains some pre-processed files, which may be easier to use in most cases. However, if you want to change some data, you have to do your changes to the underlying files, and just regenerate the usable files from there. The following section explains all that.

## Repository Structure
First, the **core** file is called *freidi-work.xml* and lives at the top level of this repo. All **sources** are contained in the *musicSources* folder, and have names like *freidi-musicSource_A.xml*. The last part of the file name matches the siglum of that source, which is also the `@xml:id` of the `<mei>` of each file. Usually, you have to modify only these files when changing data, while all other files in the repo should stay unchanged. However, **it is extremely important to make sure that the information in the core and the sources match**!!! But no worries, validation tries to help you as much as possible. Just make sure your changes still validate against both the RelaxNG and Schematron rules, and you're almost good to go.
Here's a complete list of files and folders in the repo:

 - *freidi-work.xml*: This is the main file resembling the **core** of our data model. It contains the musical content, but also the most detailed information about the relation of sources etc., plus editorial annotations. Changes to the Freischütz data normally require to edit this file.
 - *musicSources/*: This folder holds the **sources** of our data model. Each source has a separate file in here. Changes to a source require to edit the corresponding file in this folder. 
 - *schemata/*: This folder holds the *ODD* source code for the schema we use: *freidi-music-source.rng*. This file also contains a whole bunch of Schematron rules, which are essential for validation. 
 - *xslt/*: This folder contains four XSLT stylesheet which can be used to pre-process our data from the *core model* to something more common for other use cases. Actually, our edition at http://freischuetz-digital.de/edition/ depends on these pre-processed files. The XSLTs are: 
 -- *buildAnnotations.xsl*: This stylesheet is operated on *freidi-work.xml*. It extracts all editoral annotations into a format compatible with Edirom Online.
 -- *buildEdiromMeasures.xsl*: This stylesheet operates on the source files. It throws away all musical content inside `<measure>`, but keeps the measure positions on the facsimile pages. The resulting files are used to browse the sources, jump to individual measures etc. 
 -- *buildMeasureConcordance.xsl*: This file operates on *freidi-work.xml* and looks for every `<measure>`. It then processes all **sources** and identifies which measures refer to the one in the **core**. Then, a list of all these relations is generated.
 -- *buildMusic.xsl*: This stylesheet operates on the source files. In essence, it compiles the **source** with the content from the **core**. It will output multiple files of different flavors for each movement of that source that actually contains music. First, it creates files in *source_abbr*, where all abbreviations and shortcuts of the sources are kept. This partners with *source_expan*, where all abbreviations will be resolved. Both forms are combined in *source_raw*, which still contains `<choice>` and similar elements. If the stylesheet is used on *freidi-musicSource_A.xml*, there will be additional files which split up the **core** by individual movements.
 All XSLTs output there results to a folder called *ready-for-use*.
 - *ready-for-use/*: This folder contains various files which may be more appropriate for direct use. These files are described in the section above. However, it is important to not modify these files directly, but instead change the **core** and **sources** directly, and then use the provided XSLTs to re-generate them. 

## The state of this data
The files in this repo reflect the current state of the *Freischütz Digital* data. Even though the project has officially ended, they are still subject to changes. Major revisions will be made available through TextGrid for increased sustainability, while "daily" work will happen here. 
The encoded sources in this repo have a different "level of completeness". 

 - *freidi-musicSource_A.xml*: **Complete encoding** of the whole opera.
 - *freidi-musicSource_KA1.xml*: Complete for movements **6**, **8** and **9**, measure positions for the others.
 - *freidi-musicSource_KA2.xml*: Complete for movements **6**, **8** and **9**, measure positions for the others
 - *freidi-musicSource_KA9.xml*: Complete for movements **6**, **8** and **9**, measure positions for the others
 - *freidi-musicSource_K13.xml*: Complete for movements **6**, **8** and **9**, measure positions for the others
 - *freidi-musicSource_K15.xml*: Complete for movements **6**, **8** and **9**, measure positions for the others
 - *freidi-musicSource_KA19.xml*: Complete for movements **6**, **8** and **9**, measure positions for the others
 - *freidi-musicSource_K20.xml*: Complete for movements **6**, **8** and **9**, measure positions for the others
 - *freidi-musicSource_KA26.xml*: Complete for movements **6**, **8** and **9**, measure positions for the others
 - *freidi-musicSource_D1849.xml*: Complete for movements **6**, **8** and **9**, measure positions for the others
 - *freidi-musicSource_ED-kl.xml*: Measure positions *only*.
 - *freidi-musicSource_D1849B.xml*: Measure positions *only*.
 - *freidi-musicSource_D1867.xml*: Measure positions *only*.
 - *freidi-musicSource_D1871.xml*: Measure positions *only*.
 - *freidi-musicSource_DJochum.xml*: Measure positions *only*.

## License
<a rel="license" href="http://creativecommons.org/licenses/by-nc-sa/4.0/"><img alt="Creative Commons Lizenzvertrag" style="border-width:0" src="https://i.creativecommons.org/l/by-nc-sa/4.0/88x31.png" /></a><br/>All MEI-files in this repository are available under a Creative Commons CC-BY-NC-SA license. The XSLTs are available with a [AGPLv3](http://www.gnu.org/licenses/agpl-3.0.en.html) license. 
However, if you would like to use our encodings or stylesheets for something that isn't possible with these license, please contact us. 
