# Development of an Underwater Camera System for Inland Freshwater Aquaculture
Source codes on the local processor and remote processor for the development of a Raspberry Pi-based Underwater Camera System
(Source code of the underwater camera updating...)

Abstract:
Computer vision and image processing technologies are applied towards aquatic research to understand fish and its interaction to other fishes and its environment. The understanding from vision-based data acquisition and processing should aid in the development of predictive frameworks and decision support systems for efficient aquaculture monitoring and management. However, this emerging field is confronted by lack of high quality underwater visual data, whether from public or local context. Accessible underwater camera systems that obtain underwater visual data periodically and in real-time is the most desired system for such emerging studies. In this regard, an underwater camera system that captures underwater images from inland freshwater aquaculture setup is proposed. The underwater camera system devices are based on Raspberry Pi, an open-source computing platform. The Raspberry Pi-based underwater camera, enclosed in an off-the-shelf waterproof enclosure, continuously provides a real-time streaming link to the Raspberry Pi-based local processor via Power over Ethernet connection. This processor automatically captures underwater visual data, from different freshwater aquaculture setups, in the form of video frames or images every 15 min during daytime. The captured visual data is then stored into local and cloud storages (Dropbox). In addition, the local processor initiates an SSH Remote Port Forwarding Connection (via pitunnel) to allow remote view of the real-time streaming link in the local network. Furthermore, the statistics of the gathered local data are analyzed to validate if the observed characteristics can motivate application of an underwater image enhancement framework to the local data. The enhancement method used is the color balance and fusion, a hybrid enhancement framework that combines the outputs of several standalone underwater image enhancement methods through weight maps fusion. Also, the system outputs, which are collections of underwater images, are objectively evaluated to determine if the application of underwater image enhancement improves the information content and edge details of underwater images. These processes are performed in a remote high-end PC with established connection to the local devices. This camera system provides different modes of gathering data from different aquatic setups, particularly, inland freshwater aquaculture. The usage of several open-source platforms and technologies for the development of such system allows rapid prototyping, reproducibility, and flexibility. Furthermore, performing statistical analysis to the local data establishes the understanding of its characteristics. The insights from the analysis are helpful in the examination and validation of the appropriateness of applying an underwater image enhancement framework to the local data. The objective evaluation to the local data presents the appropriateness of application of color balance and fusion to local data by higher color information entropies and average gradients of the enhancement by such method, in comparison to the traditional underwater image enhancement methods.

(Updating...)
## References
* [Installation of OpenCV 4 on Raspberry Pi 4](https://www.pyimagesearch.com/2019/09/16/install-opencv-4-on-raspberry-pi-4-and-raspbian-buster/)
* [Increasing FPS on Raspberry Pi-based Camera with Python and OpenCV](https://www.pyimagesearch.com/2015/12/28/increasing-raspberry-pi-fps-with-python-and-opencv/)
* [C. O. Ancuti, C. Ancuti, C. De Vleeschouwer and P. Bekaert, "Color Balance and Fusion for Underwater Image Enhancement," in IEEE Transactions on Image Processing, vol. 27, no. 1, pp. 379-393, Jan. 2018, doi: 10.1109/TIP.2017.2759252.](https://doi.org/10.1109/TIP.2017.2759252)
* [github.com/fergaletto's MATLAB Implementation of Color Balance and Fusion, an underwater image enhancement algorithm](https://github.com/fergaletto/Color-Balance-and-fusion-for-underwater-image-enhancement.-.)
