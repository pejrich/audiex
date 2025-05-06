use base64::prelude::*;
extern crate byteorder;
use byteorder::{ByteOrder, LittleEndian, WriteBytesExt};
use itertools::interleave;
use itertools::Itertools;
use rodio::source::{SamplesConverter, Source};
use rodio::Decoder;
use rustler::{Binary, Env, NifResult, OwnedBinary};
use std::fs::File;
use std::io::BufReader;
use std::io::{Read, Seek};

#[rustler::nif]
fn write_to_file(path: String, sr: u32, audio: Vec<Binary>) -> bool {
    let spec = hound::WavSpec {
        channels: audio.len() as u16,
        sample_rate: sr,
        bits_per_sample: 16,
        sample_format: hound::SampleFormat::Int,
    };

    let mut writer = hound::WavWriter::create(path, spec).unwrap();

    let interleaved = if audio.len() == 2 {
        if let (Some(audio_left), Some(audio_right)) = (audio[0].to_owned(), audio[1].to_owned()) {
            let left_len = audio_left.as_slice().len() / 4;
            let right_len = audio_right.as_slice().len() / 4;

            let mut ch_left = vec![0.0_f32; left_len];
            let mut ch_right = vec![0.0_f32; right_len];

            LittleEndian::read_f32_into(audio_left.as_slice(), &mut ch_left);
            LittleEndian::read_f32_into(audio_right.as_slice(), &mut ch_right);
            interleave(ch_left.chunks(1), ch_right.chunks(1))
                .flatten()
                .copied()
                .collect::<Vec<f32>>()
        } else {
            return false;
        }
    } else {
        let mut f32: Vec<f32> = Vec::new();
        LittleEndian::read_f32_into(&audio[0], &mut f32);
        f32
    };

    let amplitude = i16::MAX as f32;
    for sample in interleaved {
        writer.write_sample((sample * amplitude) as i16).unwrap();
    }
    writer.finalize().unwrap();
    true
}

fn read_from_buffer<R: Read + Seek + Send + Sync + 'static>(
    env: Env,
    buf: BufReader<R>,
) -> NifResult<(Vec<Binary>, u32)> {
    let Ok(source) = Decoder::new(buf) else {
        return Err(rustler::error::Error::Atom("file_error"));
    };
    let sr = source.sample_rate();
    let ch = source.channels();
    let samples_iter: SamplesConverter<_, f32> = source.convert_samples();
    if ch == 2 {
        let mut v81: Vec<u8> = Vec::new();
        let mut v82: Vec<u8> = Vec::new();

        for (n, m) in samples_iter.tuples() {
            v81.write_f32::<LittleEndian>(n).unwrap();
            v82.write_f32::<LittleEndian>(m).unwrap();
        }
        let size = v81.len();
        let mut erl_bin: OwnedBinary = OwnedBinary::new(size).unwrap();
        let mut erl_bin2: OwnedBinary = OwnedBinary::new(size).unwrap();
        erl_bin.copy_from_slice(v81.as_slice());
        erl_bin2.copy_from_slice(v82.as_slice());
        Ok((
            vec![
                Binary::from_owned(erl_bin, env),
                Binary::from_owned(erl_bin2, env),
            ],
            sr,
        ))
    } else {
        let mut v8: Vec<u8> = Vec::new();
        for n in samples_iter {
            v8.write_f32::<LittleEndian>(n).unwrap();
        }

        let size = v8.len();
        let mut erl_bin: OwnedBinary = OwnedBinary::new(size).unwrap();
        erl_bin.copy_from_slice(v8.as_slice());

        Ok((vec![Binary::from_owned(erl_bin, env)], sr))
    }
}
#[rustler::nif]
fn read_from_file(env: Env, path: String) -> NifResult<(Vec<Binary>, u32)> {
    let Ok(fp) = File::open(path) else {
        return Err(rustler::error::Error::Atom("bad_file"));
    };
    let file = BufReader::new(fp);
    read_from_buffer(env, file)
}

#[rustler::nif]
fn read_from_base64(env: Env, b64: String) -> NifResult<(Vec<Binary>, u32)> {
    let Ok(bytes) = BASE64_STANDARD.decode(b64.as_bytes()) else {
        return Err(rustler::error::Error::Atom("decode_error"));
    };
    use std::io::Cursor;

    let buff = Cursor::new(bytes);
    let buf = BufReader::new(buff);
    read_from_buffer(env, buf)
}

rustler::init!("Elixir.Audiex.Native");
