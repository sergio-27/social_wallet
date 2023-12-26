import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:social_wallet/di/injector.dart';
import 'package:social_wallet/models/network_info_model.dart';
import 'package:social_wallet/views/screens/main/wallet/cubit/balance_cubit.dart';
import 'package:social_wallet/views/widget/cubit/network_cubit.dart';

import '../../utils/app_colors.dart';
import 'cubit/network_selector_cubit.dart';


class NetworkSelector extends StatefulWidget {

  BalanceCubit balanceCubit;
  NetworkInfoModel? selectedNetwork;
  bool? showDefaultSelected;
  Function(NetworkInfoModel? networkInfoModel)? onClickNetwork;

  NetworkSelector({Key? key, required this.balanceCubit, this.selectedNetwork, this.showDefaultSelected, this.onClickNetwork})
      : super(key: key);

  @override
  _NetworkSelectorState createState() => _NetworkSelectorState();
}

class _NetworkSelectorState extends State<NetworkSelector> {

  NetworkSelectorCubit networkSelectorCubit = getNetworkSelectorCubit();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NetworkCubit, BCNetworkState>(
      bloc: getNetworkCubit(),
      builder: (context, state) {
        if (state.status == BCNetworksStatus.initial ||
            state.status == BCNetworksStatus.loadingNetworks ||
            state.availableNetworksList == null) {
          return const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator()
            ],
          );
        }

        List<NetworkInfoModel> networksInfoList = List.empty(growable: true);

        if (state.availableNetworksList!.mainnetNetworks.isEmpty || !getKeyValueStorage().getIsMainnetEnabled()) {
          networksInfoList.addAll(state.availableNetworksList!.testnetNetworks);
        } else {
          networksInfoList.addAll(state.availableNetworksList!.mainnetNetworks);
        }

        if (widget.selectedNetwork != null || (widget.showDefaultSelected ?? false)) {
          if (widget.showDefaultSelected == true && widget.selectedNetwork == null) {
            widget.selectedNetwork = networksInfoList.first;
          }
          widget.balanceCubit.getAccountBalance(
              accountToCheck: getKeyValueStorage().getUserAddress() ?? "",
              networkInfoModel: widget.selectedNetwork!,
              networkId: widget.selectedNetwork!.id
          );
        }
        return Row(
          children: [
            Expanded(
              child: DropdownButtonHideUnderline(
                child: DropdownButton2<String>(
                  isExpanded: true,
                  hint: Row(
                    children: [
                      SvgPicture.asset(
                        "assets/ic_network.svg",
                        height: 24,
                        width: 24,
                        colorFilter: const ColorFilter.mode(Colors.black, BlendMode.srcIn),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Expanded(
                        child: Text(
                          widget.selectedNetwork != null ? widget.selectedNetwork!.name : "Select network",
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  items: networksInfoList.map((item) =>
                      DropdownMenuItem<String>(
                        value: item.name,
                        child: Text(item.name,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      )).toList(),
                  value: widget.selectedNetwork?.name,
                  onChanged: (value) {
                    NetworkInfoModel? networkInfoModel;
                    networkInfoModel = networksInfoList
                        .where((element) => element.name == value)
                        .firstOrNull;
                    if (networkInfoModel != null) {
                      if (widget.onClickNetwork != null) {
                        networkSelectorCubit.setSelectedNetwork(selectedNetworkInfo: networkInfoModel);
                        widget.onClickNetwork!(networkInfoModel);
                      }
                    }
                  },
                  buttonStyleData: ButtonStyleData(
                    height: 50,
                    width: 160,
                    padding: const EdgeInsets.only(left: 14, right: 14),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      color:  AppColors.appBackgroundColor,
                    ),
                    elevation: 2,
                  ),
                  iconStyleData: const IconStyleData(
                    icon: Icon(
                      Icons.arrow_forward_ios_outlined,
                    ),
                    iconSize: 14,
                    iconEnabledColor: Colors.black,
                    iconDisabledColor: Colors.grey,
                  ),
                  dropdownStyleData: DropdownStyleData(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      color: AppColors.appBackgroundColor,
                    ),
                    scrollbarTheme: ScrollbarThemeData(
                        radius: const Radius.circular(40),
                        thickness: MaterialStateProperty.all(6),
                        thumbVisibility: MaterialStateProperty.all(true)
                    ),
                  ),
                  menuItemStyleData: const MenuItemStyleData(
                    height: 40,
                    padding: EdgeInsets.only(left: 14, right: 14),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
