/**
 * @file laa_config.hpp
 * @brief Defines macros that need to be synced across multiple parts of the program.
 */
#pragma once
#ifndef LAA_CONFIG
#define LAA_CONFIG

#include <fcntl.h>
#include <sys/stat.h>

/**
 * Daemon Message Queue (MQ) Attributes
 */
#define LAA_MQ_NAME "/laa_d_req"
// #define LAA_MQ_OFLAG O_RDWR | O_CREAT | O_EXCL | O_NONBLOCK
// #define LAA_MQ_FLAGS O_RDWR | O_NONBLOCK
#define LAA_MQ_OFLAG O_RDWR | O_CREAT
#define LAA_MQ_FLAGS O_RDWR
#define LAA_MQ_MODE 0777
#define LAA_MQ_MAXMSG 10
#define LAA_MQ_MSGSIZE 64

#endif