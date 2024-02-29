static const float2 uniformPixelOffsets[16][16] = {
    {float2(0.25, 0.25), float2(0.25, 0.75),float2(0.75, 0.25),float2(0.75, 0.75), float2(0,0), float2(0,0), float2(0,0), float2(0,0), float2(0,0),  float2(0,0), float2(0,0), float2(0,0), float2(0,0), float2(0,0), float2(0,0), float2(0,0)},
    {float2(0.25, 0.25), float2(0.25, 0.75),float2(0.75, 0.25),float2(0.75, 0.75), float2(0,0), float2(0,0), float2(0,0), float2(0,0), float2(0,0),  float2(0,0), float2(0,0), float2(0,0), float2(0,0), float2(0,0), float2(0,0), float2(0,0)},
    {float2(0.25, 0.25), float2(0.25, 0.75),float2(0.75, 0.25),float2(0.75, 0.75), float2(0,0), float2(0,0), float2(0,0), float2(0,0), float2(0,0),  float2(0,0), float2(0,0), float2(0,0), float2(0,0), float2(0,0), float2(0,0), float2(0,0)},
    {float2(0.25, 0.25), float2(0.25, 0.75),float2(0.75, 0.25),float2(0.75, 0.75), float2(0,0), float2(0,0), float2(0,0), float2(0,0), float2(0,0),  float2(0,0), float2(0,0), float2(0,0), float2(0,0), float2(0,0), float2(0,0), float2(0,0)},
    {float2(0.1666667, 0.1666667), float2(0.1666667, 0.5), float2(0.1666667, 0.8333333), float2(0.5, 0.1666667), float2(0.5, 0.5), float2(0.5, 0.8333333), float2(0.8333333, 0.1666667), float2(0.8333333, 0.5), float2(0.8333333, 0.8333333), float2(0,0) , float2(0,0), float2(0,0), float2(0,0), float2(0,0), float2(0,0), float2(0,0)},
    {float2(0.1666667, 0.1666667), float2(0.1666667, 0.5), float2(0.1666667, 0.8333333), float2(0.5, 0.1666667), float2(0.5, 0.5), float2(0.5, 0.8333333), float2(0.8333333, 0.1666667), float2(0.8333333, 0.5), float2(0.8333333, 0.8333333), float2(0,0) , float2(0,0), float2(0,0), float2(0,0), float2(0,0), float2(0,0), float2(0,0)},
    {float2(0.1666667, 0.1666667), float2(0.1666667, 0.5), float2(0.1666667, 0.8333333), float2(0.5, 0.1666667), float2(0.5, 0.5), float2(0.5, 0.8333333), float2(0.8333333, 0.1666667), float2(0.8333333, 0.5), float2(0.8333333, 0.8333333), float2(0,0) , float2(0,0), float2(0,0), float2(0,0), float2(0,0), float2(0,0), float2(0,0)},
    {float2(0.1666667, 0.1666667), float2(0.1666667, 0.5), float2(0.1666667, 0.8333333), float2(0.5, 0.1666667), float2(0.5, 0.5), float2(0.5, 0.8333333), float2(0.8333333, 0.1666667), float2(0.8333333, 0.5), float2(0.8333333, 0.8333333), float2(0,0) , float2(0,0), float2(0,0), float2(0,0), float2(0,0), float2(0,0), float2(0,0)},
    {float2(0.1666667, 0.1666667), float2(0.1666667, 0.5), float2(0.1666667, 0.8333333), float2(0.5, 0.1666667), float2(0.5, 0.5), float2(0.5, 0.8333333), float2(0.8333333, 0.1666667), float2(0.8333333, 0.5), float2(0.8333333, 0.8333333), float2(0,0) , float2(0,0), float2(0,0), float2(0,0), float2(0,0), float2(0,0), float2(0,0)},
    {{0.125, 0.125}, {0.125, 0.375}, {0.125, 0.625}, {0.125, 0.875}, {0.375, 0.125}, {0.375, 0.375}, {0.375, 0.625}, {0.375, 0.875}, {0.625, 0.125}, {0.625, 0.375}, {0.625, 0.625}, {0.625, 0.875}, {0.875, 0.125}, {0.875, 0.375}, {0.875, 0.625}, {0.875, 0.875}},
    {{0.125, 0.125}, {0.125, 0.375}, {0.125, 0.625}, {0.125, 0.875}, {0.375, 0.125}, {0.375, 0.375}, {0.375, 0.625}, {0.375, 0.875}, {0.625, 0.125}, {0.625, 0.375}, {0.625, 0.625}, {0.625, 0.875}, {0.875, 0.125}, {0.875, 0.375}, {0.875, 0.625}, {0.875, 0.875}},
    {{0.125, 0.125}, {0.125, 0.375}, {0.125, 0.625}, {0.125, 0.875}, {0.375, 0.125}, {0.375, 0.375}, {0.375, 0.625}, {0.375, 0.875}, {0.625, 0.125}, {0.625, 0.375}, {0.625, 0.625}, {0.625, 0.875}, {0.875, 0.125}, {0.875, 0.375}, {0.875, 0.625}, {0.875, 0.875}},
    {{0.125, 0.125}, {0.125, 0.375}, {0.125, 0.625}, {0.125, 0.875}, {0.375, 0.125}, {0.375, 0.375}, {0.375, 0.625}, {0.375, 0.875}, {0.625, 0.125}, {0.625, 0.375}, {0.625, 0.625}, {0.625, 0.875}, {0.875, 0.125}, {0.875, 0.375}, {0.875, 0.625}, {0.875, 0.875}},
    {{0.125, 0.125}, {0.125, 0.375}, {0.125, 0.625}, {0.125, 0.875}, {0.375, 0.125}, {0.375, 0.375}, {0.375, 0.625}, {0.375, 0.875}, {0.625, 0.125}, {0.625, 0.375}, {0.625, 0.625}, {0.625, 0.875}, {0.875, 0.125}, {0.875, 0.375}, {0.875, 0.625}, {0.875, 0.875}},
    {{0.125, 0.125}, {0.125, 0.375}, {0.125, 0.625}, {0.125, 0.875}, {0.375, 0.125}, {0.375, 0.375}, {0.375, 0.625}, {0.375, 0.875}, {0.625, 0.125}, {0.625, 0.375}, {0.625, 0.625}, {0.625, 0.875}, {0.875, 0.125}, {0.875, 0.375}, {0.875, 0.625}, {0.875, 0.875}},
    {{0.125, 0.125}, {0.125, 0.375}, {0.125, 0.625}, {0.125, 0.875}, {0.375, 0.125}, {0.375, 0.375}, {0.375, 0.625}, {0.375, 0.875}, {0.625, 0.125}, {0.625, 0.375}, {0.625, 0.625}, {0.625, 0.875}, {0.875, 0.125}, {0.875, 0.375}, {0.875, 0.625}, {0.875, 0.875}},
};

static const float2 whiteNoisePixelOffsets[16][16] = {
    {float2(0.8117647, 0.1568628), float2(0,0), float2(0,0), float2(0,0), float2(0,0), float2(0,0), float2(0,0), float2(0,0), float2(0,0), float2(0,0), float2(0,0), float2(0,0), float2(0,0), float2(0,0), float2(0,0), float2(0,0)},
    {float2(0.3490196, 0.8666667), float2(0.352952, 0.9505198), float2(0,0), float2(0,0), float2(0,0), float2(0,0), float2(0,0), float2(0,0), float2(0,0), float2(0,0), float2(0,0), float2(0,0), float2(0,0), float2(0,0), float2(0,0), float2(0,0)},
    {float2(0.1568628, 0.6352941), float2(0.4976591, 0.4858072), float2(0.8252733, 0.7643604), float2(0,0), float2(0,0), float2(0,0), float2(0,0), float2(0,0), float2(0,0), float2(0,0), float2(0,0), float2(0,0), float2(0,0), float2(0,0), float2(0,0), float2(0,0)},
    {float2(0.003921569, 0.3529412), float2(0.07501335, 0.7318419), float2(0.8499196, 0.8382159), float2(0.9141871, 0.1630452), float2(0,0), float2(0,0), float2(0,0), float2(0,0), float2(0,0), float2(0,0), float2(0,0), float2(0,0), float2(0,0), float2(0,0), float2(0,0), float2(0,0)},
    {float2(0.8196079, 0.1098039), float2(0.4088974, 0.6403334), float2(0.1572526, 0.1905418), float2(0.7937096, 0.7762908), float2(0.04573226, 0.6018919), float2(0,0), float2(0,0), float2(0,0), float2(0,0), float2(0,0), float2(0,0), float2(0,0), float2(0,0), float2(0,0), float2(0,0), float2(0,0)},
    {float2(0.5882353, 0.7921569), float2(0.02858663, 0.8660291), float2(0.08792615, 0.5843651), float2(0.7021703, 0.5889904), float2(0.8653849, 0.200924), float2(0.0609684, 0.02144039), float2(0,0), float2(0,0), float2(0,0), float2(0,0), float2(0,0), float2(0,0), float2(0,0), float2(0,0), float2(0,0), float2(0,0)},
    {float2(0.4666667, 0.01960784), float2(0.6809738, 0.8828748), float2(0.8846487, 0.7538748), float2(0.9329593, 0.00392735), float2(0.2771723, 0.2446779), float2(0.7592461, 0.4489751), float2(0.00958252, 0.7541845), float2(0,0), float2(0,0), float2(0,0), float2(0,0), float2(0,0), float2(0,0), float2(0,0), float2(0,0), float2(0,0)},
    {float2(0.7058824, 0.07450981), float2(0.9642525, 0.9458811), float2(0.0717864, 0.5327549), float2(0.04722321, 0.9826173), float2(0.04928517, 0.1367956), float2(0.002759814, 0.4674667), float2(0.9189366, 0.4943082), float2(0.5867102, 0.8783531), float2(0,0), float2(0,0), float2(0,0), float2(0,0), float2(0,0), float2(0,0), float2(0,0), float2(0,0)},
    {float2(0.9647059, 0.772549), float2(0.5956333, 0.8459656), float2(0.4083736, 0.3874235), float2(0.2573776, 0.05804789), float2(0.9020092, 0.5815541), float2(0.9321218, 0.08051443), float2(0.197253, 0.6202174), float2(0.227621, 0.8772888), float2(0.3732584, 0.08572912), float2(0,0), float2(0,0), float2(0,0), float2(0,0), float2(0,0), float2(0,0), float2(0,0)},
    {float2(0.007843138, 0.5137255), float2(0.8445327, 0.02865553), float2(0.6173196, 0.88879), float2(0.6179036, 0.659463), float2(0.06626106, 0.8897807), float2(0.9644459, 0.1572404), float2(0.8634521, 0.6199576), float2(0.7045631, 0.7039255), float2(0.2636435, 0.1418812), float2(0.5711954, 0.1337662), float2(0,0), float2(0,0), float2(0,0), float2(0,0), float2(0,0), float2(0,0)},
    {float2(0.1568628, 0.6352941), float2(0.9234858, 0.8862184), float2(0.7575412, 0.9224153), float2(0.2163049, 0.4401021), float2(0.3633491, 0.1237838), float2(0.6154749, 0.9623257), float2(0.9999011, 0.5013394), float2(0.6234433, 0.5334573), float2(0.9481915, 0.1567411), float2(0.1072154, 0.1323576), float2(0.1606575, 0.8758186), float2(0,0), float2(0,0), float2(0,0), float2(0,0), float2(0,0)},
    {float2(0.4470588, 0.5411765), float2(0.2720743, 0.33481), float2(0.9303509, 0.05599439), float2(0.8729084, 0.9352634), float2(0.6106618, 0.6745921), float2(0.7852164, 0.3467715), float2(0.02826786, 0.01692069), float2(0.2298032, 0.1652769), float2(0.1471521, 0.4597459), float2(0.1963359, 0.9391481), float2(0.4424162, 0.04110932), float2(0.579025, 0.1308302), float2(0,0), float2(0,0), float2(0,0), float2(0,0)},
    {float2(0.1803922, 0.4784314), float2(0.5617021, 0.9069701), float2(0.6206631, 0.2381704), float2(0.8418618, 0.9688807), float2(0.06004369, 0.9833441), float2(0.6478481, 0.66399), float2(0.9041141, 0.06080914), float2(0.4308154, 0.5083014), float2(0.9069119, 0.9211274), float2(0.5165804, 0.05672526), float2(0.1417968, 0.2147882), float2(0.6453823, 0.8434319), float2(0.7880356, 0.6333113), float2(0,0), float2(0,0), float2(0,0)},
    {float2(0.7058824, 0.07450981), float2(0.7260547, 0.7307991), float2(0.6226339, 0.5658857), float2(0.625994, 0.01841402), float2(0.2275769, 0.6254475), float2(0.04689169, 0.697727), float2(0.6426663, 0.875465), float2(0.2266936, 0.439274), float2(0.9460486, 0.3512871), float2(0.2669619, 0.9145487), float2(0.9438604, 0.6633196), float2(0.3815762, 0.5400853), float2(0.7863795, 0.2837796), float2(0.1326162, 0.0382185), float2(0,0), float2(0,0)},
    {float2(0.9882353, 0.5333334), float2(0.2572514, 0.2593962), float2(0.14258, 0.6491918), float2(0.504328, 0.9736854), float2(0.1023934, 0.7872307), float2(0.8300977, 0.05190349), float2(0.5843073, 0.5394899), float2(0.5293885, 0.6227025), float2(0.4548959, 0.7779474), float2(0.02729475, 0.6506903), float2(0.8755491, 0.07380033), float2(0.6018032, 0.04733682), float2(0.8184071, 0.3800416), float2(0.920202, 0.8534645), float2(0.1117573, 0.936975), float2(0,0)},
    {float2(0.1686275, 0.7843137), float2(0.5831827, 0.2893182), float2(0.8159583, 0.1092755), float2(0.5712898, 0.6479986), float2(0.7126342, 0.9370918), float2(0.5469466, 0.02400756), float2(0.4172889, 0.08067346), float2(0.1010596, 0.2869859), float2(0.1269664, 0.1197608), float2(0.2814432, 0.88777), float2(0.273434, 0.746696), float2(0.01040709, 0.6010962), float2(0.9757165, 0.09552681), float2(0.9891824, 0.4884148), float2(0.9174973, 0.8172056), float2(0.488618, 0.4562434)},
};
    

static const float2 nrooksPixelOffset[16][16] = {
    {float2(0.07843138, 0.6588235), float2(0,0), float2(0,0), float2(0,0), float2(0,0), float2(0,0), float2(0,0), float2(0,0), float2(0,0), float2(0,0), float2(0,0), float2(0,0), float2(0,0), float2(0,0), float2(0,0), float2(0,0)},
    {float2(0.7058824, 0.07450981), float2(0.2058823, 0.07450981), float2(0,0), float2(0,0), float2(0,0), float2(0,0) , float2(0,0), float2(0,0), float2(0,0), float2(0,0), float2(0,0), float2(0,0), float2(0,0), float2(0,0), float2(0,0), float2(0,0)},
    {float2(0.5176471, 0.8313726), float2(0.1843138, 0.1647059), float2(0.5176468, 0.4980392), float2(0,0), float2(0,0) , float2(0,0), float2(0,0), float2(0,0), float2(0,0), float2(0,0), float2(0,0), float2(0,0), float2(0,0), float2(0,0), float2(0,0), float2(0,0)},
    {float2(0.8196079, 0.7137255), float2(0.8196087, 0.4637256), float2(0.06960869, 0.2137256), float2(0.3196087, 0.9637255), float2(0,0), float2(0,0) , float2(0,0), float2(0,0), float2(0,0), float2(0,0), float2(0,0), float2(0,0), float2(0,0), float2(0,0), float2(0,0), float2(0,0)},
    {float2(0.1333333, 0.5215687), float2(0.1333332, 0.1215687), float2(0.333334, 0.9215686), float2(0.5333328, 0.3215686), float2(0.7333336, 0.7215686), float2(0,0) , float2(0,0), float2(0,0), float2(0,0), float2(0,0), float2(0,0), float2(0,0), float2(0,0), float2(0,0), float2(0,0), float2(0,0)},
    {float2(0.2117647, 0.4588235), float2(0.7117643, 0.4588235), float2(0.8784313, 0.9588236), float2(0.0450983, 0.6254902), float2(0.2117643, 0.2921568), float2(0.3784313, 0.7921569), float2(0,0) , float2(0,0), float2(0,0), float2(0,0), float2(0,0), float2(0,0), float2(0,0), float2(0,0), float2(0,0), float2(0,0)},
    {float2(0.5372549, 0.3764706), float2(0.6801119, 0.9478992), float2(0.8229694, 0.805042), float2(0.9658265, 0.0907563), float2(0.1086836, 0.6621849), float2(0.2515407, 0.2336135), float2(0.3943977, 0.3764706), float2(0,0) , float2(0,0), float2(0,0), float2(0,0), float2(0,0), float2(0,0), float2(0,0), float2(0,0), float2(0,0)},
    {float2(0.01568628, 0.5411765), float2(0.390686, 0.4161766), float2(0.515686, 0.9161765), float2(0.640686, 0.04117656), float2(0.765686, 0.2911766), float2(0.890686, 0.5411765), float2(0.01568604, 0.7911765), float2(0.140686, 0.1661766), float2(0,0), float2(0,0), float2(0,0), float2(0,0), float2(0,0), float2(0,0), float2(0,0), float2(0,0)},
    {float2(0.03921569, 0.9921569), float2(0.3725491, 0.9921569), float2(0.4836597, 0.3254902), float2(0.5947714, 0.6588235), float2(0.7058821, 0.4366013), float2(0.8169937, 0.2143791), float2(0.9281044, 0.7699347), float2(0.03921604, 0.5477124), float2(0.1503267, 0.103268), float2(0,0), float2(0,0), float2(0,0), float2(0,0), float2(0,0), float2(0,0), float2(0,0)},
    {float2(0.1803922, 0.4784314), float2(0.8803921, 0.7784314), float2(0.980392, 0.2784314), float2(0.08039188, 0.3784313), float2(0.1803923, 0.07843137), float2(0.2803917, 0.6784314), float2(0.3803921, 0.9784313), float2(0.4803925, 0.4784314), float2(0.5803919, 0.1784314),float2(0,0), float2(0,0), float2(0,0), float2(0,0), float2(0,0), float2(0,0), float2(0,0)},
    {float2(0.9176471, 0.4196078), float2(0.09946525, 0.601426), float2(0.1903744, 0.8741533), float2(0.2812834, 0.1468806), float2(0.3721925, 0.6923351), float2(0.4631016, 0.2377896), float2(0.5540107, 0.4196078), float2(0.6449198, 0.9650624), float2(0.7358289, 0.3286988), float2(0.826738, 0.0559715), float2(0.9176471, 0.7832442), float2(0,0), float2(0,0), float2(0,0), float2(0,0), float2(0,0)},
    {float2(0.5058824, 0.9686275), float2(0.7558823, 0.8852941), float2(0.8392153, 0.2186275), float2(0.9225492, 0.3852941), float2(0.005882263, 0.8019608), float2(0.08921528, 0.3019608), float2(0.1725492, 0.4686275), float2(0.2558823, 0.05196083), float2(0.3392153, 0.9686275), float2(0.4225492, 0.5519608), float2(0.5058823, 0.1352941), float2(0.5892153, 0.6352941), float2(0,0), float2(0,0), float2(0,0), float2(0,0)},
    {float2(0.9529412, 0.2784314), float2(0.2606335, 0.4322775), float2(0.3375566, 0.3553545), float2(0.4144797, 0.8168929), float2(0.4914026, 0.04766214), float2(0.5683258, 0.9707391), float2(0.6452489, 0.6630468), float2(0.722172, 0.2784314), float2(0.7990949, 0.7399698), float2(0.876018, 0.893816), float2(0.9529412, 0.5861237), float2(0.02986431, 0.5092006), float2(0.1067874, 0.1245853), float2(0,0), float2(0,0), float2(0,0)},
    {float2(0.9098039, 0.9568627), float2(0.9098039, 0.02829134), float2(0.9812324, 0.1711484), float2(0.05266094, 0.9568627), float2(0.1240897, 0.3140056), float2(0.195518, 0.09971988), float2(0.2669468, 0.5282913), float2(0.3383756, 0.8854342), float2(0.4098039, 0.4568627), float2(0.4812326, 0.5997199), float2(0.5526609, 0.2425771), float2(0.6240897, 0.7425771), float2(0.695518, 0.3854342), float2(0.7669468, 0.6711484), float2(0,0), float2(0,0)},
    {float2(0.8627451, 0.6117647), float2(0.3294117, 0.4784313), float2(0.3960783, 0.1450981), float2(0.4627452, 0.5450981), float2(0.5294118, 0.2117647), float2(0.5960784, 0.945098), float2(0.662745, 0.4117647), float2(0.7294118, 0.345098), float2(0.7960784, 0.7450981), float2(0.862745, 0.8117647), float2(0.9294119, 0.2784314), float2(0.9960785, 0.07843137), float2(0.06274509, 0.01176476), float2(0.1294117, 0.8784314), float2(0.1960783, 0.6784314), float2(0,0)},
    {float2(0.4117647, 0.4235294), float2(0.6617646, 0.3610294), float2(0.7242646, 0.7360294), float2(0.7867646, 0.8610294), float2(0.8492646, 0.9860294), float2(0.9117646, 0.04852939), float2(0.9742646, 0.4860294), float2(0.03676462, 0.2985294), float2(0.09926462, 0.9235294), float2(0.1617646, 0.5485294), float2(0.2242646, 0.1110294), float2(0.2867646, 0.6110294), float2(0.3492646, 0.4235294), float2(0.4117646, 0.6735294), float2(0.4742646, 0.1735294), float2(0.5367646, 0.7985294)}
};