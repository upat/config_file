#include <stdio.h>

typedef struct date_t{
  int year;
  int month;
  int day;
}date_t;

date_t next_day(date_t date);

int main(void){
  date_t date;
  int i, loop;
  
  printf("(YYYY MM DD): "); // e.g.2001 1 1
  fflush(stdout);
  scanf("%d %d %d", &date.year, &date.month, &date.day);

  printf("何日進めますか？"); // e.g.10000
  fflush(stdout);
  scanf("%d", &loop);

  for(i=0;i<loop;i++){
    date = next_day(date);
  }

  printf("%d日進めると、%d %d %dです。", loop, date.year, date.month, date.day);
  
  return 0;
}

date_t next_day(date_t date){
  int leap = 0;
  int src_day = date.day;

  // うるう年の判定
  if(date.year % 400 == 0){
    leap = 1;
  }else if(date.year % 100 == 0){
    leap = 0;
  }else if(date.year % 4 == 0){
    leap = 1;
  }

  // 年末 -> 30日で終わらない月末 -> 30日で終わる月末の順に判定
  // どれにもヒットしない場合は日付を+1
  if(date.month == 12 && date.day == 31){
    date.year = date.year + 1;
    date.month = 1;
    date.day = 1;
  }else if((date.month == 1 && date.day == 31) || 
      (date.month == 2 && date.day == 28 && leap == 0) ||
      (date.month == 2 && date.day == 29 && leap == 1) ||
      (date.month == 3 && date.day == 31) ||
      (date.month == 5 && date.day == 31) ||
      (date.month == 7 && date.day == 31) ||
      (date.month == 8 && date.day == 31) ||
      (date.month == 10 && date.day == 31) ||
      (date.month != 1 &&
       date.month != 3 &&
       date.month != 5 &&
       date.month != 7 &&
       date.month != 8 &&
       date.month != 10 &&
       date.month != 12 && date.day == 30)){
    date.month = date.month + 1;
    date.day = 1;
  }else if(date.day < 31){
    date.day = date.day + 1;
  }

  // 範囲外の日付になってしまった時(バグった時用)
  if(date.day > 31 || date.month > 12){
    printf("null date.\n");
  }

  // 日付が変化しなかった時(バグった時用その2)
  if(src_day == date.day){
    printf("failed next day.\n");
  }

  return date;
}
