#include <iostream>

extern "C"
{
#include <libavcodec/avcodec.h>
#include <libavformat/avformat.h>
#include <libavutil/avutil.h>
#include <libavutil/imgutils.h>
#include <libswscale/swscale.h>
}

int main(int argc, char *argv[])
{
    if (argc < 2)
    {
        std::cerr << "Usage: " << argv[0] << " <remote_url>" << std::endl;
        return 1;
    }

    const char *input_url = argv[1];

    avformat_network_init();

    AVFormatContext *format_ctx = nullptr;
    if (avformat_open_input(&format_ctx, input_url, nullptr, nullptr) < 0)
    {
        std::cerr << "Could not open input URL: " << input_url << std::endl;
        return 2;
    }

    if (avformat_find_stream_info(format_ctx, nullptr) < 0)
    {
        std::cerr << "Could not find stream information" << std::endl;
        return 3;
    }

    int video_stream_idx = -1;
    for (unsigned int i = 0; i < format_ctx->nb_streams; ++i)
    {
        if (format_ctx->streams[i]->codecpar->codec_type == AVMEDIA_TYPE_VIDEO)
        {
            video_stream_idx = i;
            break;
        }
    }

    if (video_stream_idx == -1)
    {
        std::cerr << "Could not find video stream" << std::endl;
        return 4;
    }

    AVCodecParameters *codecpar = format_ctx->streams[video_stream_idx]->codecpar;
    const AVCodec *codec = avcodec_find_decoder(codecpar->codec_id);
    AVCodecContext *codec_ctx = avcodec_alloc_context3(codec);
    avcodec_parameters_to_context(codec_ctx, codecpar);

    if (avcodec_open2(codec_ctx, codec, nullptr) < 0)
    {
        std::cerr << "Could not open codec" << std::endl;
        return 5;
    }

    AVFrame *frame = av_frame_alloc();
    AVPacket *packet = av_packet_alloc();

    while (av_read_frame(format_ctx, packet) >= 0)
    {
        if (packet->stream_index == video_stream_idx)
        {
            int ret = avcodec_send_packet(codec_ctx, packet);
            if (ret < 0)
            {
                std::cerr << "Error sending packet for decoding" << std::endl;
                break;
            }

            while (ret >= 0)
            {
                ret = avcodec_receive_frame(codec_ctx, frame);
                if (ret == AVERROR(EAGAIN) || ret == AVERROR_EOF)
                {
                    break;
                }
                else if (ret < 0)
                {
                    std::cerr << "Error during decoding" << std::endl;
                    break;
                }

                std::cout << "Decoded frame: " << frame->pts << " (size: " << frame->width << "x" << frame->height
                          << ")" << std::endl;
            }
        }
        av_packet_unref(packet);
    }

    av_frame_free(&frame);
    avcodec_free_context(&codec_ctx);
    avformat_close_input(&format_ctx);

    return 0;
}