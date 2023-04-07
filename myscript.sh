#!/bin/bash

# Проверяем, не запущен ли уже скрипт
if [ -f "/tmp/analyze-log.lock" ]; then
  echo "Another instance of the script is already running."
  exit 1
else
  touch /tmp/analyze-log.lock
fi

# Устанавливаем временной диапазон
start=$(date "+%Y-%m-%d %H:%M:%S" -d "1 hour ago")
end=$(date "+%Y-%m-%d %H:%M:%S")

# Получаем данные из лог-файла
log_file="access.log"
if [ -f $log_file ]; then
  cat $log_file | awk -v start="$start" -v end="$end" '($4>"["start"]" && $4< "["end"]") {print}' > temp.log
else
  wget -O $log_file "https://cdn.otus.ru/media/private/64/40/access-4560-644067.log?hash=wHumtQd2grK57bjuuUDqeQ&expires=1680883041"
  cat $log_file | awk -v start="$start" -v end="$end" '($4>"["start"]" && $4< "["end"]") {print}' > temp.log
fi

# Список IP адресов с наибольшим кол-вом запросов
echo "IP addresses with the most requests from $start to $end:" > mail.txt
echo "===================================================" >> mail.txt
awk '{print $1}' temp.log | sort | uniq -c | sort -nr | head -n 10 >> mail.txt
echo "" >> mail.txt

# Список URL с наибольшим кол-вом запросов
echo "URLs with the most requests from $start to $end:" >> mail.txt
echo "==============================================" >> mail.txt
awk '{print $7}' temp.log | sort | uniq -c | sort -nr | head -n 10 >> mail.txt
echo "" >> mail.txt

# Ошибки веб-сервера/приложения
echo "Server/application errors from $start to $end:" >> mail.txt
echo "============================================" >> mail.txt
grep "50[0-9]" temp.log | awk '{print $9}' | sort | uniq -c | sort -nr >> mail.txt
echo "" >> mail.txt

# Список всех кодов HTTP ответа
echo "HTTP response codes and their counts from $start to $end:" >> mail.txt
echo "==================================================" >> mail.txt
awk '{print $9}' temp.log | sort | uniq -c | sort -nr >> mail.txt

# Отправляем письмо на указанный адрес
mail -s "Log analysis report from $start to $end" kpa@kliver.pro < mail.txt

# Удаляем временный файл и файл блокировки
rm -f temp.log
rm -f /tmp/analyze-log.lock
