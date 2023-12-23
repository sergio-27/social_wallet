import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_wallet/di/injector.dart';
import 'package:social_wallet/routes/app_router.dart';
import 'package:social_wallet/routes/routes.dart';
import 'package:social_wallet/utils/helpers/extensions/context_extensions.dart';
import 'package:social_wallet/views/widget/cubit/toggle_state_cubit.dart';
import 'package:social_wallet/views/widget/top_toolbar.dart';

class ConfigurationScreen extends StatefulWidget {

  bool emptyFormations = false;

  ConfigurationScreen({super.key});

  @override
  _ConfigurationScreenState createState() => _ConfigurationScreenState();
}

class _ConfigurationScreenState extends State<ConfigurationScreen> with WidgetsBindingObserver {

  ToggleStateCubit cubit = getToggleStateCubit();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TopToolbar(enableBack: true, toolbarTitle: "Configuration"),
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              BlocBuilder<ToggleStateCubit, ToggleStateState>(
                bloc: cubit,
                builder: (context, state) {
                  return Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                              child: Text(
                                getKeyValueStorage().getIsMainnetEnabled() ? "Mainnet enabled" : "Testnet enabled",
                                style: context.bodyTextMedium.copyWith(
                                    fontSize: 18,
                                    color: Colors.black,
                                    fontWeight: FontWeight.w500
                                ),
                              )
                          ),
                          Switch(
                            value: getKeyValueStorage().getIsMainnetEnabled(),
                            onChanged: (bool value) {
                              getKeyValueStorage().setMainnetEnabled(value);
                              cubit.toggleState();
                              getNetworkCubit().getAvailableNetworks();
                            },
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
              TextButton(
                  onPressed: () {
                    getKeyValueStorage().resetKeys();
                    AppRouter.pushNamed(RouteNames.LoginScreenRoute.name);
                  },
                  child: const Text(
                      "Log out"
                  )
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
