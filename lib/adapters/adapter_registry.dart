import 'package:knkpanime/adapters/adapter_base.dart';
import 'package:knkpanime/adapters/anime1_adapter.dart';
import 'package:knkpanime/adapters/bimi_adapter.dart';
import 'package:knkpanime/adapters/girigirilove_adapter.dart';
import 'package:knkpanime/adapters/iyf_adapter.dart';
import 'package:knkpanime/adapters/ant_adapter.dart';
import 'package:knkpanime/adapters/nyafun_adapter.dart';
import 'package:knkpanime/adapters/yhdm_adapter.dart';

final adapters = <AdapterBase>[
  GirigiriLoveAdapter(),
  BimiAdapter(),
  //YhdmAdapter(),
  Anime1Adapter(),
  IyfAdapter(),
  AntAdapter(),
  NyafunAdapter(),
];
