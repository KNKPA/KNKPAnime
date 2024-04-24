import 'package:knkpanime/adapters/adapter_base.dart';
import 'package:knkpanime/adapters/anime1_adapter.dart';
import 'package:knkpanime/adapters/bimi_adapter.dart';
import 'package:knkpanime/adapters/girigirilove_adapter.dart';
import 'package:knkpanime/adapters/iyf_adapter.dart';
import 'package:knkpanime/adapters/yhdm_adapter.dart';

final adapters = <AdapterBase>[
  GirigiriLoveAdapter(),
  BimiAdapter(),
  Anime1Adapter(),
  IyfAdapter(),
  //YhdmAdapter(),
];
