#include <stdio.h>
#include <stdlib.h>
#include "gengeo.h"
#include <string.h>
#include <unistd.h>
#include <math.h>

const char *Options = "d:s:o:f:t:a:m:";
const char* distributions[2] = {"GEOMETRIC","NONE"};
const char* modes[2] = {"data","time"};
const char* file_paths[2] = {"patterns","on-off-secuences"};
int on_time = 0, off_time = 0, sess_length = 0, avg_iat = 0, sess_duration = 0;
double inter_arrival_time = 0.0;
int seed = 0; //Default seed

enum Distribution
{
    geometric,
    none
};

enum Mode
{
    time,
    data
};

enum Distribution dist = none;
enum Mode mode = data;

void usage(char* prog){
    fprintf( stderr,"usage: %s -d dist [GEOMETRIC|NONE] -s seed -o on_time -f off_time -t session_duration -a mean_arrival_time -m mode[time|data]\n",prog);
    exit(2);
}

void gen_file_name(char* output_file, char* output_file_csv){

  char tmp_string[10], file_title[40];
  memset(file_title, '\0', sizeof(file_title));
  strcat(file_title,distributions[dist]);
  strcat(file_title,"_");
  sprintf(tmp_string,"%d",seed);
  strcat(file_title,tmp_string);
  strcat(file_title,"_");
  memset(tmp_string, '\0', sizeof(tmp_string));
  sprintf(tmp_string,"%d",on_time);
  strcat(file_title,tmp_string);
  strcat(file_title,"_");
  memset(tmp_string, '\0', sizeof(tmp_string));
  sprintf(tmp_string,"%d",off_time);
  strcat(file_title,tmp_string);
  strcat(file_title,"_");
  memset(tmp_string, '\0', sizeof(tmp_string));
  sprintf(tmp_string,"%d",sess_duration);
  strcat(file_title,tmp_string);
  strcat(file_title,"_");
  memset(tmp_string, '\0', sizeof(tmp_string));
  sprintf(tmp_string,"%.3f",inter_arrival_time);
  strcat(file_title,tmp_string);
  memset(output_file, '\0', sizeof(60));
  memset(output_file_csv, '\0', sizeof(55));
  strcpy(output_file,file_title);
  strcpy(output_file_csv,file_title);
  strcat(output_file,"_on_off_sec.txt");
  strcat(output_file_csv,"_on_off.csv");
}

//===== Main program ========================================================
int main(int argc, char** argv)
{
  char output_file[60];
  char output_file_csv[55];
  int first_entry = 0;
  char* input_string;    // Input string
  FILE   *fp, *fp_on_off;
  int c;
  int errflg = 0;
  int on_packets = 0, off_packets = 0;
  double p_on = 0.0;
  double p_off = 0.0;

  int calculated_delay; // Probability of success for geometric
  int    geo_rv_on = 0;
  int    geo_rv_off = 0;             // Geometric random variable
  int    i = 0;                   // shapping counter

   while ((c = getopt(argc, argv, Options)) != -1) {
        switch(c) {
        case 'd':
            input_string = optarg;

            if(strcmp(input_string,distributions[0]) == 0){
                dist = geometric;
            }
            break;
        case 's':
            input_string = optarg;
            seed = atoi(input_string);
            break;
        case 'o':
            input_string = optarg;
            on_time = atoi(input_string);
            break;
        case 'f':
            input_string = optarg;
            off_time = atoi(input_string);
            break;
        case 't':
            input_string = optarg;
            sess_duration = atoi(input_string);
            break;
        case 'a':
            input_string = optarg;
            inter_arrival_time = atof(input_string);
            break;
        case 'm':
            input_string = optarg;
            if(strcmp(input_string,modes[0]) != 0){
            mode = time;
            }
            break;
        case ':':
            fprintf(stderr,
                "Option -%c requires an operand\n", optopt);
            errflg++;
            break;
        case '?':
            fprintf(stderr,
                "Unrecognized option: '-%c'\n", optopt);
            errflg++;
            break;
        default:
           usage(argv[0]);
        }
    }
    if (argc == 1 || argc > optind || errflg > 0 || optind < 6) {
        usage(argv[0]);
    }



  gen_file_name(output_file,output_file_csv);

  //Opening file
  fp = fopen(output_file, "w");
  if (fp == NULL)
  {
    printf("ERROR in creating output file (%s) \n", output_file);
    exit(1);
  }
  fp_on_off = fopen(output_file_csv, "w");

  if (fp_on_off == NULL)
  {
    printf("ERROR in creating output file (%s) \n", output_file_csv);
    exit(1);
  }

  switch(dist){
      case geometric:
          rand_val(seed);
          if(mode == data){
          if(inter_arrival_time > 0){
                avg_iat = floor(inter_arrival_time * 1000);
                on_time = on_time * 1000;
                off_time = off_time * 1000;
                sess_duration = floor(sess_duration * 1000);
                on_packets = floor(on_time/avg_iat);
                off_packets = floor(off_time/avg_iat);
                p_on = pow((off_packets +1),-1);
                p_off = pow((on_packets +1),-1);
                sess_length = floor(sess_duration/avg_iat);
            }

  // Generate and output geometric random variables
          if(sess_length > 0){
              first_entry = 1;
              fprintf(fp, "%d,%d",1,1);
            while (i < sess_length)
                {
                    geo_rv_on = geo(p_on);
                    geo_rv_off = geo(p_off);
                    calculated_delay = geo_rv_off * avg_iat;
                    if(first_entry == 1){
                        i = geo_rv_on;
                        fprintf(fp, ",%d,%d", i + 1,calculated_delay);
                        fprintf(fp, ",%d,%d", i + 2,1);
                        first_entry = 0;

                    }
                    i += (geo_rv_on + geo_rv_off);
                    if(i < sess_length){
                        fprintf(fp_on_off, "%d, %d\n", geo_rv_on, geo_rv_off);
                        fprintf(fp, ",%d,%d", i + 1, calculated_delay);
                        fprintf(fp, ",%d,%d", i + 2, 1);

                    }
                }
                seed = geo_rv_on+geo_rv_off;
                printf("%d",seed);
            }
          }else{

                on_time = on_time * 1000;
                off_time = off_time * 1000;
                sess_duration = floor(sess_duration * 1000);
                p_on = pow((off_time + 1),-1) * on_time;
                p_off = pow((off_time +off_time),-1) * off_time;

                // Generate and output geometric random variables
          if(sess_duration > 0){
              first_entry = 1;
              fprintf(fp, "%d,%d",1,1);
            while (i < sess_duration)
                {
                    geo_rv_on = geo(p_on);
                    geo_rv_off = geo(p_off);
                    calculated_delay = geo_rv_off;
                    if(first_entry == 1){
                        i = geo_rv_on;
                        fprintf(fp, ",%d,%d", i + 1,calculated_delay);
                        fprintf(fp, ",%d,%d", i + 2,1);
                        first_entry = 0;

                    }
                    i += (geo_rv_on + geo_rv_off);
                    if(i < sess_duration){
                        fprintf(fp_on_off, "%d, %d\n", geo_rv_on, geo_rv_off);
                        fprintf(fp, ",%d,%d", i + 1, calculated_delay);
                        fprintf(fp, ",%d,%d", i + 2, 1);

                    }
                }
                seed = geo_rv_on+geo_rv_off;
                printf("%d",seed);
            }
          }

      break;
      case none:
      if(mode == data){
                if(inter_arrival_time > 0){
                avg_iat = floor(inter_arrival_time * 1000);
                on_time = on_time * 1000;
                off_time = off_time * 1000;
                sess_duration = floor(sess_duration * 1000);
                on_packets = floor(on_time/avg_iat);
                off_packets = floor(off_time/avg_iat);
                sess_length = floor(sess_duration/avg_iat);
            }

          // Generate and output deterministic pattern
          if(sess_length > 0){
              first_entry = 1;
              fprintf(fp, "%d,%d",1,1);
            while (i < sess_length)
                {
                    if(first_entry == 1){
                        i = on_packets;
                        fprintf(fp, ",%d,%d", i + 1,off_time);
                        fprintf(fp, ",%d,%d", i + 2,1);
                        first_entry = 0;

                    }
                    i += (on_packets + off_packets);
                    if(i < sess_length){
                        fprintf(fp_on_off, "%d, %d\n", on_packets ,off_packets);
                        fprintf(fp, ",%d,%d", i + 1,off_time);
                        fprintf(fp, ",%d,%d", i + 2,1);

                    }
                }
                seed++;
                printf("%d",seed);
            }
      }else{
                on_time = on_time * 1000;
                off_time = off_time * 1000;
                sess_duration = floor(sess_duration * 1000);


          // Generate and output deterministic pattern
          if(sess_duration > 0){
              first_entry = 1;
              fprintf(fp, "%d,%d",1,1);
            while (i < sess_duration)
                {
                    if(first_entry == 1){
                        i = on_time;
                        fprintf(fp, ",%d,%d", i + 1,off_time);
                        fprintf(fp, ",%d,%d", i + 2,1);
                        first_entry = 0;

                    }
                    i += (on_time + off_time);
                    if(i < sess_duration){
                        fprintf(fp_on_off, "%d, %d\n", on_time ,off_time);
                        fprintf(fp, ",%d,%d", i + 1,off_time);
                        fprintf(fp, ",%d,%d", i + 2,1);

                    }
                }
                seed++;
                printf("%d",seed);
            }
      }


        break;
        }


  fclose(fp_on_off);
  fclose(fp);




return EXIT_SUCCESS;
}
