# lab9-bash

Скрипт начинается с проверки на наличие файла блокировки /tmp/analyze-log.lock, 
который используется для предотвращения запуска нескольких копий скрипта одновременно. 
Если файл существует, скрипт завершается
