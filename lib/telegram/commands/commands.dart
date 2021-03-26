// ignore_for_file: import_of_legacy_library_into_null_safe

library commands;

import 'dart:async';

import 'package:args/args.dart';
import 'package:bloc/bloc.dart';
import 'package:litgame_telegram/core/core.dart';
import 'package:litgame_telegram/core/src/bloc/game/game_flow/process.dart';
import 'package:litgame_telegram/core/src/bloc/game/invite/process.dart';
import 'package:litgame_telegram/core/src/bloc/game/kick/process.dart';
import 'package:litgame_telegram/core/src/bloc/game/main/process.dart';
import 'package:litgame_telegram/core/src/bloc/game/setup_game/process.dart';
import 'package:litgame_telegram/core/src/bloc/game/training/process.dart';
import 'package:meta/meta.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';
import 'package:pedantic/pedantic.dart';
import 'package:teledart/model.dart';
import 'package:teledart_app/teledart_app.dart';

part 'chat/endgame.dart';
part 'chat/startgame.dart';
part 'game_command.dart';
part 'pm/addcollection.dart';
part 'pm/delcollection.dart';
part 'pm/help.dart';
part 'pm/mixin/ask_access_mix.dart';
part 'system/finishjoin.dart';
part 'system/gameflow.dart';
part 'system/joinme.dart';
part 'system/kickme.dart';
part 'system/mixin/copychat_mix.dart';
part 'system/mixin/endturn_mix.dart';
part 'system/mixin/image_mix.dart';
part 'system/selectadmin.dart';
part 'system/setcollection.dart';
part 'system/setmaster.dart';
part 'system/setorder.dart';
part 'system/trainingflow.dart';
