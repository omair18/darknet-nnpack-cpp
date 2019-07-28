#include <darknet2.h>
#include <time.h>
#include <stdlib.h>
#include <stdio.h>
#include "opencv2/opencv.hpp" 
#include "highgui.h"
#include "detect_obj.h"

void video_test(char * _video) ; 



int main(int argc,char **argv)
{
    video_test(argv[1]);
    return 0 ;    
}
//use this function to process video for detecting object
void video_test(char * _video)
{

    detect_obj * detect_yolo = new detect_obj();
    if(!detect_yolo->load_net("/home/wq/darknet/cfg/coco.data", \
      "/home/wq/darknet/cfg/yolov3.cfg", "/home/wq/darknet/yolov3.weights",\
      "/home/wq/darknet/data/names.list") ) 
        return ;

    CvCapture * capture = cvCreateFileCapture(_video);
    IplImage * frame ;
    unsigned short count = 0 ;
    while (1){
        count ++ ;

       frame = cvQueryFrame(capture);
       if (count%3==0)
       {
            detect_result result = detect_yolo->to_detection(frame,0.45,0.5,0.5) ; 
            free_detections(result.dets, result.nboxes);
       }
      // char c = cvWaitKey(33);
       //if(c==27) break ;
    }
    cvReleaseCapture(&capture);
}
